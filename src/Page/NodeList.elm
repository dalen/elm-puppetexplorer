module Page.NodeList exposing (..)

import Html exposing (Html, text)
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
import View.Toolbar as Toolbar
import Material
import Material.List as Lists
import Material.Layout as Layout
import Material.Spinner as Spinner
import Material.Textfield as Textfield


type alias Model =
    { list : Scroll.Model Node
    }


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
            |> Task.map Model


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


type Msg
    = ScrollMsg (Scroll.Msg Node)


grow : Msg
grow =
    ScrollMsg Scroll.Grow


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ScrollMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    Scroll.update subMsg model.list
            in
                ( { model | list = subModel }, Cmd.map ScrollMsg subCmd )


view :
    Material.Model
    -> (Material.Msg msg -> msg)
    -> Model
    -> Route.NodeListParams
    -> Date.Date
    -> (Msg -> msg)
    -> Page.Page msg
view mdlModel mdlMsg model routeParams date msg =
    Page.pageWithoutTabs
        (Scroll.isGrowing model.list)
        (Toolbar.Custom
            [ Layout.title [] [ text "Nodes" ]
            , Layout.spacer
            , Textfield.render mdlMsg
                [ 0 ]
                mdlModel
                [ Textfield.label "Expandable"
                , Textfield.floatingLabel
                , Textfield.expandable "nodelist-query"
                , Textfield.expandableIcon "search"
                ]
                []
            ]
        )
        (Html.map msg
            (Html.div []
                [ Lists.ul
                    []
                    (List.map (nodeListView date routeParams) (Scroll.items model.list))
                , Spinner.spinner [ Spinner.active (Scroll.isGrowing model.list) ]
                ]
            )
        )


nodeListView : Date.Date -> Route.NodeListParams -> Node -> Html Msg
nodeListView date routeParams node =
    let
        timeAgo =
            case node.reportTimestamp of
                Just reportDate ->
                    Html.text (Util.dateDistance date reportDate)

                Nothing ->
                    Html.text "No report for node"
    in
        Html.a [ Route.href (Route.NodeDetail (Route.NodeDetailParams node.certname Nothing routeParams.query)) ]
            [ Lists.li [ Lists.withSubtitle ]
                [ Lists.content []
                    [ text node.certname
                    , Lists.subtitle [] [ timeAgo ]
                    ]
                , Lists.content2 []
                    [ Status.icon node.latestReportStatus
                    ]
                ]
            ]
