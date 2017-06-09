module Page.NodeList exposing (..)

import Html exposing (Html)
import PuppetDB
import Material.List as Lists
import Material.Color as Color
import Material.Icon as Icon
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


view : Model -> Route.NodeListParams -> Date.Date -> Html Never
view model routeParams date =
    Lists.ul [] (List.map (nodeListView date routeParams) model.nodeList)


nodeListView : Date.Date -> Route.NodeListParams -> Node -> Html Never
nodeListView date routeParams node =
    let
        timeAgo =
            case node.reportTimestamp of
                Just reportDate ->
                    Html.text (Util.dateDistance date reportDate)

                Nothing ->
                    Icon.i "help"
    in
        Lists.li [ Lists.withSubtitle ]
            [ Lists.content []
                [ Html.a [ Route.href (Route.NodeDetail (Route.NodeDetailParams node.certname Nothing routeParams.query)) ]
                    [ Html.text node.certname ]
                , Lists.subtitle [] [ timeAgo ]
                ]
            , Lists.content2
                []
                [ Status.listIcon node.latestReportStatus ]
            ]
