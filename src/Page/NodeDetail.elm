module Page.NodeDetail exposing (..)

import Html exposing (Html, text)
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
import View.Toolbar as Toolbar
import Http
import Util
import Scroll
import Material
import Material.List as Lists
import Material.Spinner as Spinner
import Material.Options as Options


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
    | Mdl (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ScrollMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    Scroll.update subMsg model.list
            in
                ( { model | list = subModel }, Cmd.map ScrollMsg subCmd )

        Mdl mdl ->
            ( model, Cmd.none )


view : Model -> Route.NodeDetailParams -> Date -> (Msg -> msg) -> Page.Page msg
view model routeParams date msg =
    Page.pageWithoutTabs
        False
        (Toolbar.Title routeParams.node)
        (Html.div []
            [ Lists.ul []
                (List.map (reportListItemView date routeParams) (Scroll.items model.list))
            , Options.div [ Options.center ]
                [ Spinner.spinner [ Spinner.active (Scroll.isGrowing model.list) ]
                ]
            ]
        )


reportListItemView : Date -> Route.NodeDetailParams -> Report -> Html msg
reportListItemView date routeParams report =
    let
        -- ISO format without milliseconds
        formattedDate =
            Date.Extra.toFormattedString "YYYY-MM-DDThh:mm:ssX" report.receiveTime

        timeAgo =
            Html.text (Util.dateDistance date report.receiveTime)
    in
        Html.a [ Route.href (Route.Report (Route.ReportParams report.hash Route.Report.Events)) ]
            [ Lists.li [ Lists.withSubtitle ]
                [ Lists.content []
                    [ text formattedDate
                    , Lists.subtitle [] [ timeAgo ]
                    ]
                , Status.icon report.status
                ]
            ]
