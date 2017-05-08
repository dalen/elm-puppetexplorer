module NodeList exposing (..)

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
import Date
import Date.Distance
import Status
import Routing
import Navigation
import Config


type alias NodeListItem =
    { certname : String
    , reportTimestamp : Maybe Date.Date
    , latestReportStatus : Status.Status
    }


type alias Model =
    { nodeList : WebData (List NodeListItem)
    }


type Msg
    = UpdateNodeListMsg (WebData (List NodeListItem))
    | NewUrlMsg Routing.Route


init : ( Model, Cmd Msg )
init =
    ( { nodeList = RemoteData.NotAsked
      }
    , Cmd.none
    )


load : Config.Config -> Model -> Maybe String -> ( Model, Cmd Msg )
load config model query =
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateNodeListMsg response ->
            ( { model | nodeList = response }, Cmd.none )

        NewUrlMsg route ->
            ( model, Navigation.newUrl (Routing.toString route) )


view : Model -> Maybe String -> Date.Date -> Html.Html Msg
view model query date =
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
                , tbody = Table.tbody [] (List.map (nodeListItemView date query) nodes)
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
        Table.tr [] [ Table.td [] [ (Routing.link (Routing.NodeDetailRoute node.certname Nothing query) NewUrlMsg) [ Html.text node.certname ] ], timeAgo, status ]


nodeListDecoder : Json.Decode.Decoder (List NodeListItem)
nodeListDecoder =
    Json.Decode.list nodeListItemDecoder


nodeListItemDecoder : Json.Decode.Decoder NodeListItem
nodeListItemDecoder =
    Json.Decode.Pipeline.decode NodeListItem
        |> Json.Decode.Pipeline.required "certname" Json.Decode.string
        |> Json.Decode.Pipeline.required "report_timestamp" (Json.Decode.nullable Json.Decode.Extra.date)
        |> Json.Decode.Pipeline.required "latest_report_status" Status.decoder
