module NodeList exposing (..)

import Html
import Html.Attributes
import PuppetDB
import RemoteData exposing (WebData)
import FontAwesome.Web as Icon
import Bootstrap.Progress as Progress
import Bootstrap.Table as Table
import Date
import Date.Distance
import Status
import Routing
import Config
import Error
import Task exposing (Task)
import View.Page as Page
import Page.Errored as Errored exposing (PageLoadError)
import PuppetDB.Node exposing (Node)
import Http


type alias Model =
    { nodeList : List Node
    }


init : Config.Config -> Routing.NodeListRouteParams -> Task PageLoadError Model
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



{-
   initModel : Model
   initModel =
       { nodeList = RemoteData.NotAsked
       }


   load : Config.Config -> Model -> Routing.NodeListRouteParams -> ( Model, Cmd Msg )
   load config model routeParams =
       ( { model | nodeList = RemoteData.Loading }
       , PuppetDB.queryPQL
           config.serverUrl
           (PuppetDB.pql "nodes"
               [ "certname"
               , "report_timestamp"
               , "latest_report_status"
               ]
               ((PuppetDB.subquery "inventory" routeParams.query)
                   ++ "order by certname"
               )
           )
           PuppetDB.Node.listDecoder
           UpdateNodeListMsg
       )

   type Msg
       = UpdateNodeListMsg (WebData (List Node))
       | NewUrlMsg Routing.Route

   update : Msg -> Model -> ( Model, Cmd Msg )
   update msg model =
       case msg of
           UpdateNodeListMsg response ->
               ( { model | nodeList = response }, Cmd.none )

           NewUrlMsg route ->
               ( model, Routing.newUrl route )
-}


view : Model -> Routing.NodeListRouteParams -> Date.Date -> Html.Html Never
view model routeParams date =
    Table.table
        { options = [ Table.striped ]
        , thead =
            Table.simpleThead
                [ Table.th [] []
                , Table.th [] [ Html.text "Last run" ]
                , Table.th [] [ Html.text "Status" ]
                ]
        , tbody = Table.tbody [] (List.map (nodeListView date routeParams) model.nodeList)
        }


nodeListView : Date.Date -> Routing.NodeListRouteParams -> Node -> Table.Row Never
nodeListView date routeParams node =
    let
        status =
            case node.latestReportStatus of
                Status.Changed ->
                    Table.td []
                        [ Html.span [ Html.Attributes.class "text-warning" ] [ Icon.exclamation_circle ]
                        ]

                Status.Unchanged ->
                    Table.td []
                        [ Html.span [ Html.Attributes.class "text-success" ] [ Icon.exclamation_circle ]
                        ]

                Status.Failed ->
                    Table.td []
                        [ Html.span [ Html.Attributes.class "text-danger" ] [ Icon.warning ]
                        ]

                Status.Unknown ->
                    Table.td [] [ Icon.question_circle ]

        timeAgo =
            case node.reportTimestamp of
                Just reportDate ->
                    Table.td []
                        [ Html.text (Date.Distance.inWords date reportDate) ]

                Nothing ->
                    Table.td [] [ Icon.question_circle ]
    in
        Table.tr []
            [ Table.td []
                [ Html.a [ Routing.href (Routing.NodeDetailRoute (Routing.NodeDetailRouteParams node.certname Nothing routeParams.query)) ] [ Html.text node.certname ]
                ]
            , timeAgo
            , status
            ]
