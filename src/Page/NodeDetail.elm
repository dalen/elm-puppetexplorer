module Page.NodeDetail exposing (..)

import Html exposing (Html)
import PuppetDB
import PuppetDB.Report exposing (Report)
import Json.Decode
import Material.List as Lists
import Material.Options as Options
import Date exposing (Date)
import Date.Extra
import Status exposing (Status)
import Config exposing (Config)
import Route
import Task exposing (Task)
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import Http
import Util
import Scroll exposing (ScrollInfo)


type alias Model =
    { routeParams : Route.NodeDetailParams
    , growing : Bool
    , reportList : List Report
    , reportCount : Int
    }


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
    Task.map2 (Model params False)
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
    | OnScroll ScrollInfo


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

        OnScroll scrollInfo ->
            ( { model | growing = True }, Cmd.none )


view : Model -> Route.NodeDetailParams -> Date -> Page.Page Msg
view model routeParams date =
    { title = routeParams.node
    , content =
        Options.div [ Options.css "overflow-y" "scroll", Scroll.onScroll OnScroll ]
            [ Lists.ul [] (List.map (reportListItemView date routeParams) model.reportList)
            ]
    }


reportListItemView : Date -> Route.NodeDetailParams -> Report -> Html msg
reportListItemView date routeParams report =
    let
        -- ISO format without milliseconds
        formattedDate =
            Date.Extra.toFormattedString "YYYY-MM-DDThh:mm:ssX" report.receiveTime

        timeAgo =
            Html.text (Util.dateDistance date report.receiveTime)
    in
        Html.a [ Route.href (Route.Report (Route.ReportParams report.hash Nothing routeParams.query)) ]
            [ Lists.li [ Lists.withSubtitle ]
                [ Lists.content []
                    [ Html.text formattedDate
                    , Lists.subtitle [] [ timeAgo ]
                    ]
                , Lists.content2
                    []
                    [ Status.listIcon report.status ]
                ]
            ]


reportListCountDecoder : Json.Decode.Decoder Int
reportListCountDecoder =
    Json.Decode.index 0 (Json.Decode.field "count" Json.Decode.int)
