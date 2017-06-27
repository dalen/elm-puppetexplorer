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
import Scroll
import Polymer.Paper as Paper
import Polymer.Attributes exposing (boolProperty)


type alias Model =
    Scroll.Model Node


perLoad : Int
perLoad =
    50


init : Config.Config -> Route.NodeListParams -> Task PageLoadError Model
init config params =
    let
        handleLoadError _ =
            Errored.pageLoadError Page.Nodes "Failed to load list of nodes."
    in
        Task.map (Scroll.setItems (Scroll.init perLoad (nodeListRequest config.serverUrl params.query))) (getNodeList config.serverUrl params.query)
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
                ++ " limit "
                ++ toString perLoad
            )
        )
        PuppetDB.Node.listDecoder



-- update


type alias Msg =
    Scroll.Msg Node


grow : Msg
grow =
    Scroll.Grow


update : Msg -> Model -> ( Model, Cmd Msg )
update =
    Scroll.update


view : Model -> Route.NodeListParams -> Date.Date -> Html Msg
view model routeParams date =
    Html.div []
        [ Html.Keyed.node "div"
            []
            (List.map (nodeListView date routeParams) (Scroll.items model))
        , Paper.spinner [ boolProperty "active" (Scroll.isGrowing model) ] []
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
