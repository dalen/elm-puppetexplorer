module Page.NodeList exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (attribute)
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
    Html.div [] (List.map (nodeListView date routeParams) model.nodeList)


nodeListView : Date.Date -> Route.NodeListParams -> Node -> Html Never
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
            [ Paper.item []
                [ Paper.itemBody [ attribute "two-line" "" ]
                    [ Html.div [] [ text node.certname ]
                    , Html.div [ attribute "secondary" "" ] [ timeAgo ]
                    ]
                , Status.icon node.latestReportStatus
                ]
            ]
