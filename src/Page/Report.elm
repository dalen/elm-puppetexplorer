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
import Http
import Util
import Material.Grid as Grid
import Material.List as Lists
import Material.Icon as Icon
import Material.Options as Options
import Material.Table as Table
import Material.Typography as Typography
import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Set


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
        |> Task.mapError (Errored.httpError Page.Nodes "loading report")


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
    , tabs = ( [ text "Events", text "Logs", text "Metrics" ], [] )
    , selectedTab = Route.Report.toIndex routeParams.tab
    , onSelectTab = Just (SelectTab >> msg)
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
                    metricsView model.report.metrics
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


metricCategories : List PuppetDB.Report.Metric -> List String
metricCategories metrics =
    List.foldl (\metric categories -> Set.insert metric.category categories) Set.empty metrics
        |> Set.toList


metricsForCategory : String -> List PuppetDB.Report.Metric -> List PuppetDB.Report.Metric
metricsForCategory category metrics =
    let
        unsortedMetrics =
            List.foldl
                (\metric filteredMetrics ->
                    if metric.category == category then
                        List.append filteredMetrics [ metric ]
                    else
                        filteredMetrics
                )
                []
                metrics
    in
        -- Make sure we put the total last in the list
        List.append
            (List.filter (\metric -> metric.name /= "total") unsortedMetrics)
            (List.filter (\metric -> metric.name == "total") unsortedMetrics)


metricsView : List PuppetDB.Report.Metric -> Html msg
metricsView metrics =
    Grid.grid []
        (metricCategories metrics
            |> List.map
                (metricsCategoryView metrics)
        )


metricsCategoryView : List PuppetDB.Report.Metric -> String -> Grid.Cell msg
metricsCategoryView metrics category =
    Grid.cell [ Grid.size Grid.All 4 ]
        [ Options.styled Html.p
            [ Typography.subhead, Typography.capitalize ]
            [ text category ]
        , Table.table
            []
            [ Table.tbody []
                (metricsForCategory category metrics
                    |> List.map
                        (\metric ->
                            Table.tr []
                                [ Table.td
                                    [ Typography.capitalize
                                    , Typography.body2 |> Options.when (metric.name == "total")
                                    ]
                                    [ text metric.name ]
                                , Table.td [ Typography.body2 |> Options.when (metric.name == "total") ]
                                    [ text
                                        (if (floor metric.value) == (ceiling metric.value) then
                                            (toString metric.value)
                                         else
                                            (FormatNumber.format { usLocale | decimals = 2 } metric.value)
                                        )
                                    ]
                                ]
                        )
                )
            ]
        ]
