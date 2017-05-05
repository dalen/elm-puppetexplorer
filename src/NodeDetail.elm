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
import Bootstrap.Progress
import Bootstrap.Table as Table
import Date
import Date.Distance


init : Config -> String -> Model -> ( Model, Cmd Msg )
init config node model =
    case model.route of
        NodeListRoute query ->
            ( { model | nodeList = RemoteData.Loading }
            , PuppetDB.queryPQL
                config.serverUrl
                (PuppetDB.pql "nodes"
                    [ "certname"
                    , "report_timestamp"
                    , "latest_report_status"
                    ]
                    "order by certname"
                    query
                )
                nodeListDecoder
                UpdateNodeListMsg
            )

        _ ->
            ( model, Cmd.none )


view : Config -> Model -> Html.Html Msg
view config model =
    case model.nodeList of
        RemoteData.Success nodes ->
            Table.table
                { options = [ Table.striped ]
                , thead =
                    Table.simpleThead
                        [ Table.th [] []
                        , Table.th [] [ Html.text "Last run" ]
                        , Table.th [] [ Html.text "Status" ]
                        ]
                , tbody = Table.tbody [] (List.map (nodeListItemView model.date) nodes)
                }

        _ ->
            Bootstrap.Progress.progress
                [ Bootstrap.Progress.label "Loading configuration..."
                , Bootstrap.Progress.animated
                ]


nodeListItemView : Date.Date -> NodeListItem -> Table.Row Msg
nodeListItemView date node =
    let
        status =
            case node.latestReportStatus of
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
            case node.reportTimestamp of
                Just reportDate ->
                    Table.td []
                        [ Html.text (Date.Distance.inWords date reportDate) ]

                Nothing ->
                    Table.td [] [ Icon.question_circle ]
    in
        Table.tr [] [ Table.td [] [ Html.text node.certname ], timeAgo, status ]


nodeListDecoder : Json.Decode.Decoder (List NodeListItem)
nodeListDecoder =
    Json.Decode.list nodeListItemDecoder


nodeListItemDecoder : Json.Decode.Decoder NodeListItem
nodeListItemDecoder =
    Json.Decode.Pipeline.decode NodeListItem
        |> Json.Decode.Pipeline.required "certname" Json.Decode.string
        |> Json.Decode.Pipeline.required "report_timestamp" (Json.Decode.nullable Json.Decode.Extra.date)
        |> Json.Decode.Pipeline.required "latest_report_status"
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
