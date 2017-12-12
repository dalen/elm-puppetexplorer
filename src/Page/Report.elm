module Page.Report exposing (..)

import PuppetDB
import PuppetDB.Report exposing (Report)
import Html exposing (Html, text)
import Html.Attributes as Attr
import Date exposing (Date)
import Route
import Route.Report exposing (Tab(..))
import Config exposing (Config)
import Json.Decode
import Task exposing (Task)
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import View.Toolbar as Toolbar
import View.EventList as EventList
import View.LogList as LogList
import View.ReportMetrics as ReportMetrics
import Http
import Util
import Material.Grid as Grid
import Material.List as Lists
import Material.Icon as Icon
import Material.Options as Options
import FormatNumber
import FormatNumber.Locales exposing (usLocale)


type alias Model =
    { routeParams : Route.ReportParams
    , report : PuppetDB.Report.Report
    }


type Msg
    = ChangePage Int
    | SelectTab Int


init : Config.Config -> Route.ReportParams -> Task PageLoadError Model
init config params =
    Task.map (Model params)
        (getReport config.serverUrl params.hash)


getReport : String -> String -> Task PageLoadError Report
getReport serverUrl hash =
    PuppetDB.request
        serverUrl
        (PuppetDB.pql "reports"
            []
            ("hash=\""
                ++ hash
                ++ "\""
            )
        )
        (Json.Decode.index 0 PuppetDB.Report.decoder)
        |> Http.toTask
        |> Task.mapError (Errored.httpError "loading report" >> Errored.pageLoadError Page.Nodes)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTab tab ->
            let
                routeParams =
                    model.routeParams
            in
                ( model, Route.newUrl (Route.Report { routeParams | tab = Route.Report.fromIndex tab }) )

        ChangePage page ->
            let
                routeParams =
                    model.routeParams
            in
                ( model
                , Route.newUrl (Route.Report routeParams)
                )


item : String -> String -> Html msg -> Html msg
item title icon content =
    Lists.li [ Lists.withSubtitle ]
        [ Lists.content []
            [ Lists.icon icon []
            , text title
            , Lists.subtitle [] [ content ]
            ]
        ]


view : Model -> Route.ReportParams -> Date -> (Msg -> msg) -> Page.Page msg
view model routeParams date msg =
    { loading = False
    , toolbar = Toolbar.Title ("Report for " ++ model.report.certname)

    {- }    , tabs = ( [ text "Events", text "Logs", text "Metrics" ], [] )
       , selectedTab = Route.Report.toIndex routeParams.tab
       , onSelectTab = Just (SelectTab >> msg)
    -}
    , content =
        Html.div []
            [ Grid.grid []
                [ Grid.cell [ Grid.size Grid.Phone 4, Grid.size Grid.Tablet 4, Grid.size Grid.Desktop 6, Options.css "margin-bottom" "0" ]
                    [ Lists.ul [ Options.css "padding" "0" ]
                        [ item "Environment" "label_outline" (text model.report.environment)
                        , item "Run time" "schedule" (showMetric 1 (Just "s") "time" "total" model.report)
                        , item "Configuration version"
                            "assignment"
                            (text model.report.configurationVersion)
                        , item "Puppet version" "receipt" (text model.report.puppetVersion)
                        ]
                    ]
                , Grid.cell [ Grid.size Grid.Phone 4, Grid.size Grid.Tablet 4, Grid.size Grid.Desktop 6, Options.css "margin-top" "0" ]
                    [ Lists.ul [ Options.css "padding" "0" ]
                        [ item "Catalog retrieval time" "assignment_returned" (showMetric 1 (Just "s") "time" "total" model.report)
                        , item "Catalog compiled by"
                            "build"
                            (case model.report.producer of
                                Just producer ->
                                    text producer

                                Nothing ->
                                    Icon.view "help" []
                            )
                        , item "Start time" "flight_takeoff" (text (Util.formattedDate model.report.startTime))
                        , item "End time" "flight_land" (text (Util.formattedDate model.report.endTime))
                        ]
                    ]
                ]
            , Html.hr [ Attr.class "divider" ] []
            , (case routeParams.tab of
                Events ->
                    EventList.view date model.report.resourceEvents

                Logs ->
                    LogList.view date model.report.logs

                Metrics ->
                    ReportMetrics.view model.report.metrics
              )
            ]
    }


showMetric : Int -> Maybe String -> String -> String -> Report -> Html msg
showMetric decimals unit name category report =
    case (PuppetDB.Report.getMetric "time" "total" report) of
        Just metric ->
            text
                ((FormatNumber.format { usLocale | decimals = decimals } metric)
                    ++ (Maybe.withDefault "" unit)
                )

        Nothing ->
            Icon.view "help" []
