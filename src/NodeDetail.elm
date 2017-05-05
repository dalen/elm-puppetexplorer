module NodeDetail exposing (..)

import Html
import Html.Attributes
import Types exposing (..)
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


init : Config -> String -> Model -> ( Model, Cmd Msg )
init config node model =
    case model.nodeReportList of
        RemoteData.Loading ->
            ( model, Cmd.none )

        _ ->
            ( { model | nodeReportList = RemoteData.Loading }
            , PuppetDB.queryPQL
                config.serverUrl
                (PuppetDB.pql "reports"
                    [ "receive_time"
                    , "status"
                    ]
                    "order by receive_time desc limit 10"
                )
                reportListDecoder
                UpdateNodeReportListMsg
            )


view : Config -> String -> Model -> Html.Html Msg
view config node model =
    Html.div []
        [ Html.h1 [] [ Html.text node ]
        , Grid.simpleRow
            [ Grid.col
                [ Col.md6 ]
                [ reportList model.date model.nodeReportList ]
            ]
        ]


reportList : Date.Date -> WebData (List NodeReportListItem) -> Html.Html Msg
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


reportListItemView : Date.Date -> NodeReportListItem -> Table.Row Msg
reportListItemView date report =
    let
        status =
            case report.status of
                Changed ->
                    Table.td []
                        [ Html.span [ Html.Attributes.class "text-warning" ] [ Icon.exclamation_circle ]
                        ]

                Unchanged ->
                    Table.td []
                        [ Html.span [ Html.Attributes.class "text-success" ] [ Icon.exclamation_circle ]
                        ]

                Failed ->
                    Table.td []
                        [ Html.span [ Html.Attributes.class "text-danger" ] [ Icon.warning ]
                        ]

                Unknown ->
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


reportListDecoder : Json.Decode.Decoder (List NodeReportListItem)
reportListDecoder =
    Json.Decode.list reportListItemDecoder


reportListItemDecoder : Json.Decode.Decoder NodeReportListItem
reportListItemDecoder =
    Json.Decode.Pipeline.decode NodeReportListItem
        |> Json.Decode.Pipeline.required "receive_time" (Json.Decode.nullable Json.Decode.Extra.date)
        |> Json.Decode.Pipeline.required "status"
            (Json.Decode.oneOf
                [ Json.Decode.string
                    |> Json.Decode.andThen
                        (Json.Decode.Extra.fromResult
                            << (\val ->
                                    case val of
                                        "changed" ->
                                            Ok Changed

                                        "unchanged" ->
                                            Ok Unchanged

                                        "failed" ->
                                            Ok Failed

                                        _ ->
                                            Err "Unknown value"
                               )
                        )
                , Json.Decode.null Unknown
                ]
            )
