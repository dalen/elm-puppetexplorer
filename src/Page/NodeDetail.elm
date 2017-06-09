module Page.NodeDetail exposing (..)

import Html
import Html.Attributes
import Html.Events
import PuppetDB
import PuppetDB.Report exposing (Report)
import Json.Decode
import Material.Icon as Icon
import Bootstrap.Table as Table
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Date
import Date.Distance
import Pagination
import Status exposing (Status)
import Config exposing (Config)
import Route
import Task exposing (Task)
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import Http


type alias Model =
    { routeParams : Route.NodeDetailParams
    , reportList : List Report
    , reportCount : Int
    }



{-
   type alias ReportListItem =
       { hash : String
       , reportTimestamp : Maybe Date.Date
       , status : Status
       }
-}


perPage : Int
perPage =
    10


offset : Maybe Int -> Int
offset page =
    case page of
        Just page ->
            (page - 1) * perPage

        Nothing ->
            0


init : Config.Config -> Route.NodeDetailParams -> Task PageLoadError Model
init config params =
    Task.map2 (Model params)
        (getReportList config.serverUrl params.node (offset params.page))
        (getReportCount config.serverUrl params.node)


getReportList : String -> String -> Int -> Task PageLoadError (List Report)
getReportList serverUrl node offset =
    PuppetDB.request
        serverUrl
        (PuppetDB.pql "reports"
            []
            ("certname=\""
                ++ node
                ++ "\" order by receive_time desc offset "
                ++ toString offset
                ++ " limit "
                ++ toString perPage
            )
        )
        PuppetDB.Report.listDecoder
        |> Http.toTask
        |> Task.mapError (Errored.httpError Page.Nodes "loading list of reports")


getReportCount : String -> String -> Task PageLoadError Int
getReportCount serverUrl node =
    PuppetDB.request
        serverUrl
        (PuppetDB.pql "reports"
            [ "count()" ]
            ("certname=\""
                ++ node
                ++ "\""
            )
        )
        reportListCountDecoder
        |> Http.toTask
        |> Task.mapError (\_ -> Errored.pageLoadError Page.Nodes "Failed to load count of nodes")


type Msg
    = ChangePage Int
    | ViewReport String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangePage page ->
            let
                routeParams =
                    model.routeParams
            in
                ( model
                , Route.newUrl (Route.NodeDetail { routeParams | page = Just page })
                )

        ViewReport hash ->
            ( model
            , Route.newUrl (Route.Report { hash = hash, page = Nothing, query = model.routeParams.query })
            )


view : Model -> Route.NodeDetailParams -> Date.Date -> Page.Page Msg
view model routeParams date =
    { title = routeParams.node
    , content =
        Grid.simpleRow
            [ Grid.col
                [ Col.md6 ]
                [ reportList date model.reportList
                , pagination model
                ]
            ]
    }


reportList : Date.Date -> List Report -> Html.Html Msg
reportList date reports =
    Table.table
        { options = [ Table.striped ]
        , thead =
            Table.simpleThead
                [ Table.th [] [ Html.text "Last run" ]
                , Table.th [] [ Html.text "Status" ]
                ]
        , tbody = Table.tbody [] (List.map (reportListItemView date) reports)
        }


reportListItemView : Date.Date -> Report -> Table.Row Msg
reportListItemView date report =
    let
        status =
            case report.status of
                Status.Changed ->
                    Table.td []
                        [ Html.span [ Html.Attributes.class "text-warning" ] [ Icon.i "done" ]
                        ]

                Status.Unchanged ->
                    Table.td []
                        [ Html.span [ Html.Attributes.class "text-success" ] [ Icon.i "check_box" ]
                        ]

                Status.Failed ->
                    Table.td []
                        [ Html.span [ Html.Attributes.class "text-danger" ] [ Icon.i "error" ]
                        ]

                Status.Unknown ->
                    Table.td [] [ Icon.i "help" ]

        {- }
           timeAgo =
               case report.receiveTime of
                   Just reportDate ->
                       Table.td []
                           [ Html.text (Date.Distance.inWords date reportDate) ]

                   Nothing ->
                       Table.td [] [ Icon.question_circle ]
        -}
        timeAgo =
            Table.td []
                [ Html.text (Date.Distance.inWords date report.receiveTime) ]
    in
        Table.tr [ Table.rowAttr (Html.Events.onClick (ViewReport report.hash)) ] [ timeAgo, status ]


pagination : Model -> Html.Html Msg
pagination model =
    Pagination.config ChangePage
        |> Pagination.activePage (Maybe.withDefault 1 model.routeParams.page)
        |> Pagination.items (model.reportCount // perPage + 1)
        |> Pagination.view


reportListCountDecoder : Json.Decode.Decoder Int
reportListCountDecoder =
    Json.Decode.index 0 (Json.Decode.field "count" Json.Decode.int)
