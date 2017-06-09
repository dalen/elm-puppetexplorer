module NodeList exposing (..)

import Html exposing (Html)
import PuppetDB
import Material.List as Lists
import Material.Color as Color
import FontAwesome.Web as Icon
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


type alias Model =
    { nodeList : List Node
    }


init : Config.Config -> Route.NodeListParams -> Task PageLoadError Model
init config params =
    let
        handleLoadError _ =
            Errored.pageLoadError Page.Nodes "Failed to load list of nodes."
    in
        Task.map Model (getNodeList config.serverUrl params.query)
            |> Task.mapError handleLoadError


getNodeList : String -> Maybe String -> Task PageLoadError (List Node)
getNodeList serverUrl query =
    PuppetDB.request
        serverUrl
        (PuppetDB.pql "nodes"
            [ "certname"
            , "report_timestamp"
            , "latest_report_status"
            ]
            ((PuppetDB.subquery "inventory" query)
                ++ "order by certname"
            )
        )
        PuppetDB.Node.listDecoder
        |> Http.toTask
        |> Task.mapError (\_ -> Errored.pageLoadError Page.Nodes "Failed to load list of nodes")


view : Model -> Route.NodeListParams -> Date.Date -> Html.Html Never
view model routeParams date =
    Lists.ul [] (List.map (nodeListView date routeParams) model.nodeList)


nodeListView : Date.Date -> Route.NodeListParams -> Node -> Html Never
nodeListView date routeParams node =
    let
        status =
            case node.latestReportStatus of
                Status.Changed ->
                    Lists.icon "check_circle" [ Color.text (Color.color Color.Green Color.S500) ]

                Status.Unchanged ->
                    Lists.icon "done" []

                Status.Failed ->
                    Lists.icon "error" [ Color.text (Color.color Color.Red Color.S500) ]

                Status.Unknown ->
                    Lists.icon "help" []

        timeAgo =
            case node.reportTimestamp of
                Just reportDate ->
                    Html.text (Util.dateDistance date reportDate)

                Nothing ->
                    Icon.question_circle
    in
        Lists.li [ Lists.withSubtitle ]
            [ Lists.content []
                [ Html.a [ Route.href (Route.NodeDetail (Route.NodeDetailParams node.certname Nothing routeParams.query)) ]
                    [ Html.text node.certname ]
                , Lists.subtitle [] [ timeAgo ]
                ]
            , Lists.content2
                []
                [ status ]
            ]
