module View.ReportMetrics exposing (..)

import PuppetDB.Report exposing (Report)
import Html exposing (Html, text)
import Material.Grid as Grid
import Material.Options as Options
import Material.Typography as Typography
import Set
import Chart


view : List PuppetDB.Report.Metric -> Html msg
view metrics =
    Grid.grid []
        (metricCategories metrics
            |> List.map
                (categoryView metrics)
        )


{-| View for one metric category
-}
categoryView : List PuppetDB.Report.Metric -> String -> Grid.Cell msg
categoryView metrics category =
    Grid.cell [ Grid.size Grid.All 4 ]
        [ Options.styled Html.p
            [ Typography.subhead, Typography.capitalize ]
            [ text category ]
        , Chart.pie (metricsToData (metricsForCategory category metrics))
            |> Chart.addValueToLabel
            |> Chart.dimensions 400 300
            |> Chart.colors chartColors
            |> Chart.toHtml
        ]


{-| Return a list of the metric categories. Takes a list of all metrics.
-}
metricCategories : List PuppetDB.Report.Metric -> List String
metricCategories metrics =
    List.foldl (\metric categories -> Set.insert metric.category categories) Set.empty metrics
        |> Set.toList


{-| Given a category and all metrics, return a sorted list of metrics belonging to that category
-}
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
        -- Remove the total from the list
        (List.filter (\metric -> metric.name /= "total") unsortedMetrics)


{-| Turn list of metrics to list of data for chart library
-}
metricsToData : List PuppetDB.Report.Metric -> List ( Float, String )
metricsToData metrics =
    List.map (\metric -> ( metric.value, metric.name )) metrics


chartColors : List String
chartColors =
    [ "#F44336"
    , "#E91E63"
    , "#9C27B0"
    , "#673AB7"
    , "#3F51B5"
    , "#2196F3"
    , "#03A9F4"
    , "#00BCD4"
    , "#009688"
    , "#4CAF50"
    , "#8BC34A"
    , "#CDDC39"
    , "#FFEB3B"
    , "#FFC107"
    , "#FF9800"
    , "#FF5722"
    , "#795548"
    , "#607D8B"
    ]
