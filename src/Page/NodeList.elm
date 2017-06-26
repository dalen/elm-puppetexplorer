module Page.NodeList exposing (..)

import Html exposing (Html, text)
import Html.Attributes as Attr exposing (attribute, class)
import Html.Keyed
import PuppetDB
import Date
import Status
import Route
import Config
import Task exposing (Task)
import View.Page as Page
import Page.Errored as Errored exposing (PageLoadError)
import PuppetDB.Node exposing (Node)
import Http
import Util
import Polymer.Paper as Paper
import Polymer.Attributes exposing (boolProperty)


type alias Model =
    { loadMore : Int -> Http.Request (List Node)
    , loading : Bool
    , nodeList : List Node
    }


init : Config.Config -> Route.NodeListParams -> Task PageLoadError Model
init config params =
    let
        handleLoadError _ =
            Errored.pageLoadError Page.Nodes "Failed to load list of nodes."
    in
        Task.map (Model (nodeListRequest config.serverUrl params.query) False) (getNodeList config.serverUrl params.query)
            |> Task.mapError handleLoadError


getNodeList : String -> Maybe String -> Task PageLoadError (List Node)
getNodeList serverUrl query =
    nodeListRequest serverUrl query 0
        |> Http.toTask
        |> Task.mapError (\_ -> Errored.pageLoadError Page.Nodes "Failed to load list of nodes")


nodeListRequest : String -> Maybe String -> Int -> Http.Request (List Node)
nodeListRequest serverUrl query offset =
    PuppetDB.request
        serverUrl
        (PuppetDB.pql "nodes"
            [ "certname"
            , "report_timestamp"
            , "latest_report_status"
            ]
            ((PuppetDB.subquery "inventory" query)
                ++ "order by certname offset "
                ++ toString offset
                ++ " limit 10"
            )
        )
        PuppetDB.Node.listDecoder



-- update


type Msg
    = LoadMore
    | OnLoadMore (Result Http.Error (List Node))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "NodeList.update" msg
    in
        case msg of
            LoadMore ->
                ( { model | loading = True }
                , (if model.loading then
                    Cmd.none
                   else
                    model.loadMore (List.length model.nodeList)
                        |> Http.send OnLoadMore
                  )
                )

            OnLoadMore (Err _) ->
                ( { model | loading = False }, Cmd.none )

            OnLoadMore (Ok result) ->
                ( { model
                    | loading = False
                    , nodeList = List.concat [ model.nodeList, result ]
                  }
                , Cmd.none
                )


view : Model -> Route.NodeListParams -> Date.Date -> Html Msg
view model routeParams date =
    Html.div []
        [ Html.Keyed.node "div"
            []
            (List.map (nodeListView date routeParams) model.nodeList)
        , Paper.spinner [ boolProperty "active" model.loading ] []
        ]


nodeListView : Date.Date -> Route.NodeListParams -> Node -> ( String, Html Msg )
nodeListView date routeParams node =
    let
        timeAgo =
            case node.reportTimestamp of
                Just reportDate ->
                    Html.text (Util.dateDistance date reportDate)

                Nothing ->
                    Html.text "No report for node"
    in
        ( "node-" ++ node.certname
        , Html.a [ Route.href (Route.NodeDetail (Route.NodeDetailParams node.certname Nothing routeParams.query)) ]
            [ Paper.item []
                [ Paper.itemBody [ attribute "two-line" "" ]
                    [ Html.div [] [ text node.certname ]
                    , Html.div [ attribute "secondary" "" ] [ timeAgo ]
                    ]
                , Status.icon node.latestReportStatus
                ]
            ]
        )
