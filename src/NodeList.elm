module NodeList exposing (..)

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
import Date
import Date.Distance
import Link


init : Config -> Model -> ( Model, Cmd Msg )
init config model =
    case model.route of
        NodeListRoute query ->
            ( { model | nodeList = RemoteData.Loading }
            , PuppetDB.queryPQL
                config.serverUrl
                (PuppetDB.pqlInventory "nodes"
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


view : Config -> Maybe String -> Model -> Html.Html Msg
view config query model =
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
                , tbody = Table.tbody [] (List.map (nodeListItemView model.date query) nodes)
                }

        _ ->
            Progress.progress
                [ Progress.label "Loading nodes..."
                , Progress.animated
                , Progress.value 100
                ]


nodeListItemView : Date.Date -> Maybe String -> NodeListItem -> Table.Row Msg
nodeListItemView date query node =
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
        Table.tr [] [ Table.td [] [ Link.link (NodeDetailRoute node.certname query) [ Html.text node.certname ] ], timeAgo, status ]


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
