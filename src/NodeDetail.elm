module NodeDetail exposing (..)

import Html
import Html.Attributes
import PuppetDB
import Json.Decode
import Json.Decode.Extra
import Json.Decode.Pipeline
import RemoteData exposing (WebData)
import FontAwesome.Web as Icon
import Bootstrap.Progress as Progress
import Bootstrap.Table as Table
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Date
import Date.Distance
import Pagination
import Status exposing (Status)
import Config exposing (Config)


type Msg
    = ChangePage Int
    | UpdateReportList (WebData (List ReportListItem))
    | UpdateReportListCount (WebData Int)


type alias Model =
    { reportList : WebData (List ReportListItem)
    , reportCount : WebData Int
    }


type alias ReportListItem =
    { reportTimestamp : Maybe Date.Date
    , status : Status
    }


init : ( Model, Cmd Msg )
init =
    ( { reportList = RemoteData.NotAsked
      , reportCount = RemoteData.NotAsked
      }
    , Cmd.none
    )


load : Config -> Model -> String -> Maybe Int -> ( Model, Cmd Msg )
load config model node page =
    let
        offset =
            case page of
                Just page ->
                    (page - 1) * 10

                Nothing ->
                    0
    in
        ( { reportList = RemoteData.Loading, reportCount = RemoteData.Loading }
        , Cmd.batch
            [ PuppetDB.queryPQL
                config.serverUrl
                (PuppetDB.pql "reports"
                    [ "receive_time"
                    , "status"
                    ]
                    ("order by receive_time desc offset "
                        ++ toString offset
                        ++ " limit 10"
                    )
                )
                reportListDecoder
                UpdateReportList
            , PuppetDB.queryPQL
                config.serverUrl
                (PuppetDB.pql "reports"
                    [ "count()" ]
                    ("")
                )
                reportListCountDecoder
                UpdateReportListCount
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateReportList response ->
            ( { model | reportList = response }, Cmd.none )

        UpdateReportListCount response ->
            ( { model | reportCount = response }, Cmd.none )

        ChangePage page ->
            ( model, Cmd.none )


view : Model -> String -> Maybe Int -> Date.Date -> Html.Html Msg
view model node page date =
    Html.div []
        [ Html.h1 [] [ Html.text node ]
        , Grid.simpleRow
            [ Grid.col
                [ Col.md6 ]
                [ reportList date model.reportList
                , Pagination.config ChangePage |> Pagination.items 20 |> Pagination.view
                ]
            ]
        ]


reportList : Date.Date -> WebData (List ReportListItem) -> Html.Html Msg
reportList date reports =
    case reports of
        RemoteData.Success reports ->
            Table.table
                { options = [ Table.striped ]
                , thead =
                    Table.simpleThead
                        [ Table.th [] [ Html.text "Last run" ]
                        , Table.th [] [ Html.text "Status" ]
                        ]
                , tbody = Table.tbody [] (List.map (reportListItemView date) reports)
                }

        _ ->
            Progress.progress
                [ Progress.label "Loading reports..."
                , Progress.animated
                , Progress.value 100
                ]


reportListItemView : Date.Date -> ReportListItem -> Table.Row Msg
reportListItemView date report =
    let
        status =
            case report.status of
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
            case report.reportTimestamp of
                Just reportDate ->
                    Table.td []
                        [ Html.text (Date.Distance.inWords date reportDate) ]

                Nothing ->
                    Table.td [] [ Icon.question_circle ]
    in
        Table.tr [] [ timeAgo, status ]


reportListDecoder : Json.Decode.Decoder (List ReportListItem)
reportListDecoder =
    Json.Decode.list reportListItemDecoder


reportListCountDecoder : Json.Decode.Decoder Int
reportListCountDecoder =
    Json.Decode.index 0 (Json.Decode.field "count" Json.Decode.int)


reportListItemDecoder : Json.Decode.Decoder ReportListItem
reportListItemDecoder =
    Json.Decode.Pipeline.decode ReportListItem
        |> Json.Decode.Pipeline.required "receive_time" (Json.Decode.nullable Json.Decode.Extra.date)
        |> Json.Decode.Pipeline.required "status" Status.decoder
