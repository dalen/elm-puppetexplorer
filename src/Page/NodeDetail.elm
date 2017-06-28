module Page.NodeDetail exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (attribute)
import Html.Keyed
import PuppetDB
import PuppetDB.Report exposing (Report)
import Date exposing (Date)
import Date.Extra
import Status exposing (Status)
import Config exposing (Config)
import Route
import Route.Report
import Task exposing (Task)
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import Http
import Util
import Scroll
import Polymer.Paper as Paper
import Polymer.Attributes exposing (boolProperty)


type alias Model =
    { list : Scroll.Model Report
    }


perLoad : Int
perLoad =
    50


init : Config.Config -> Route.NodeDetailParams -> Task PageLoadError Model
init config params =
    Task.map
        (Scroll.setItems (Scroll.init perLoad (reportListRequest config.serverUrl params.node)))
        (getReportList config.serverUrl params.node)
        |> Task.map Model


{-| Create a Http.Request for a list of reports
-}
reportListRequest : String -> String -> Int -> Http.Request (List Report)
reportListRequest serverUrl node offset =
    PuppetDB.request
        serverUrl
        (PuppetDB.pql "reports"
            []
            ("certname=\""
                ++ node
                ++ "\" order by receive_time desc offset "
                ++ toString offset
                ++ " limit "
                ++ toString perLoad
            )
        )
        PuppetDB.Report.listDecoder


getReportList : String -> String -> Task PageLoadError (List Report)
getReportList serverUrl node =
    reportListRequest serverUrl node 0
        |> Http.toTask
        |> Task.mapError (Errored.httpError Page.Nodes "loading list of reports")


type Msg
    = ScrollMsg (Scroll.Msg Report)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ScrollMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    Scroll.update subMsg model.list
            in
                ( { model | list = subModel }, Cmd.map ScrollMsg subCmd )


view : Model -> Route.NodeDetailParams -> Date -> Page.Page Msg
view model routeParams date =
    { title = routeParams.node
    , onScroll = Nothing
    , content =
        Html.div
            []
            [ Html.Keyed.node "div"
                [ Html.Attributes.id "node-detail" ]
                (List.map (reportListItemView date routeParams) (Scroll.items model.list))
            , Paper.spinner [ boolProperty "active" (Scroll.isGrowing model.list) ] []
            ]
    }


reportListItemView : Date -> Route.NodeDetailParams -> Report -> ( String, Html msg )
reportListItemView date routeParams report =
    let
        -- ISO format without milliseconds
        formattedDate =
            Date.Extra.toFormattedString "YYYY-MM-DDThh:mm:ssX" report.receiveTime

        timeAgo =
            Html.text (Util.dateDistance date report.receiveTime)
    in
        ( "node-report-" ++ "report.hash"
        , Html.a [ Route.href (Route.Report (Route.ReportParams report.hash Route.Report.Events)) ]
            [ Paper.item []
                [ Paper.itemBody [ attribute "two-line" "" ]
                    [ Html.div [] [ text formattedDate ]
                    , Html.div [ attribute "secondary" "" ] [ timeAgo ]
                    ]
                , Status.icon report.status
                ]
            ]
        )
