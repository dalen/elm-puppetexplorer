module Page.NodeDetail exposing (..)

import Html exposing (Html)
import PuppetDB
import PuppetDB.Report exposing (Report)
import Json.Decode
import Material.List as Lists
import Date
import Status exposing (Status)
import Config exposing (Config)
import Route
import Task exposing (Task)
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import Http
import Util


type alias Model =
    { routeParams : Route.NodeDetailParams
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


view : Model -> Route.NodeDetailParams -> Date.Date -> Page.Page Msg
view model routeParams date =
    { title = routeParams.node
    , content = Lists.ul [] (List.map (reportListItemView date routeParams) model.reportList)
    }


reportListItemView : Date.Date -> Route.NodeDetailParams -> Report -> Html msg
reportListItemView date routeParams report =
    let
        timeAgo =
            Html.text (Util.dateDistance date report.receiveTime)
    in
        Lists.li [ Lists.withSubtitle ]
            [ Lists.content []
                [ Html.a [ Route.href (Route.Report (Route.ReportParams report.hash Nothing routeParams.query)) ]
                    [ Html.text report.hash ]
                , Lists.subtitle [] [ timeAgo ]
                ]
            , Lists.content2
                []
                [ Status.listIcon report.status ]
            ]


reportListCountDecoder : Json.Decode.Decoder Int
reportListCountDecoder =
    Json.Decode.index 0 (Json.Decode.field "count" Json.Decode.int)
