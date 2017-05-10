module NodeDetail exposing (..)

import Html
import Html.Attributes
import Html.Events
import PuppetDB
import Json.Decode
import Json.Decode.Extra
import Json.Decode.Pipeline
import RemoteData exposing (WebData)
import FontAwesome.Web as Icon
import Bootstrap.Alert as Alert
import Bootstrap.Progress as Progress
import Bootstrap.Table as Table
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Date
import Date.Distance
import Pagination
import Status exposing (Status)
import Config exposing (Config)
import Routing


type Msg
    = ChangePage Int
    | UpdateReportList (WebData (List ReportListItem))
    | UpdateReportListCount (WebData Int)
    | ViewReport String


type alias Model =
    { routeParams : Routing.NodeDetailRouteParams
    , reportList : WebData (List ReportListItem)
    , reportCount : WebData Int
    }


type alias ReportListItem =
    { hash : String
    , reportTimestamp : Maybe Date.Date
    , status : Status
    }


perPage : Int
perPage =
    10


initModel : Model
initModel =
    { routeParams = Routing.NodeDetailRouteParams "" Nothing Nothing
    , reportList = RemoteData.NotAsked
    , reportCount = RemoteData.NotAsked
    }


load : Config -> Model -> Routing.NodeDetailRouteParams -> ( Model, Cmd Msg )
load config model routeParams =
    let
        offset =
            case routeParams.page of
                Just page ->
                    (page - 1) * perPage

                Nothing ->
                    0
    in
        ( { model
            | reportList = RemoteData.Loading
            , reportCount = RemoteData.Loading
            , routeParams = routeParams
          }
        , Cmd.batch
            [ PuppetDB.queryPQL
                config.serverUrl
                (PuppetDB.pql "reports"
                    [ "hash", "receive_time", "status" ]
                    ("certname=\""
                        ++ routeParams.node
                        ++ "\" order by receive_time desc offset "
                        ++ toString offset
                        ++ " limit "
                        ++ toString perPage
                    )
                )
                reportListDecoder
                UpdateReportList
            , PuppetDB.queryPQL
                config.serverUrl
                (PuppetDB.pql "reports"
                    [ "count()" ]
                    ("certname=\""
                        ++ routeParams.node
                        ++ "\""
                    )
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
            let
                routeParams =
                    model.routeParams
            in
                ( model
                , Routing.newUrl (Routing.NodeDetailRoute { routeParams | page = Just page })
                )

        ViewReport hash ->
            ( model
            , Routing.newUrl (Routing.ReportRoute { hash = hash, page = Nothing, query = model.routeParams.query })
            )


view : Model -> Routing.NodeDetailRouteParams -> Date.Date -> Html.Html Msg
view model routeParams date =
    Html.div []
        [ Html.h1 [] [ Html.text routeParams.node ]
        , Grid.simpleRow
            [ Grid.col
                [ Col.md6 ]
                [ reportList date model.reportList
                , pagination model
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
        Table.tr [ Table.rowAttr (Html.Events.onClick (ViewReport report.hash)) ] [ timeAgo, status ]


pagination : Model -> Html.Html Msg
pagination model =
    case model.reportCount of
        RemoteData.Success count ->
            Pagination.config ChangePage
                |> Pagination.activePage (Maybe.withDefault 1 model.routeParams.page)
                |> Pagination.items (count // perPage + 1)
                |> Pagination.view

        RemoteData.Failure error ->
            Alert.warning [ Html.text (toString error) ]

        _ ->
            Icon.spinner


reportListDecoder : Json.Decode.Decoder (List ReportListItem)
reportListDecoder =
    Json.Decode.list reportListItemDecoder


reportListCountDecoder : Json.Decode.Decoder Int
reportListCountDecoder =
    Json.Decode.index 0 (Json.Decode.field "count" Json.Decode.int)


reportListItemDecoder : Json.Decode.Decoder ReportListItem
reportListItemDecoder =
    Json.Decode.Pipeline.decode ReportListItem
        |> Json.Decode.Pipeline.required "hash" Json.Decode.string
        |> Json.Decode.Pipeline.required "receive_time" (Json.Decode.nullable Json.Decode.Extra.date)
        |> Json.Decode.Pipeline.required "status" Status.decoder
