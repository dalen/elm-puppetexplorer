module View.ReportMetrics exposing (..)

import PuppetDB.Report exposing (Report)
import Html exposing (Html, text)
import Material.Options as Options
import Material.Typography as Typography
import Material.Card as Card
import Material.Grid as Grid
import Material.Elevation as Elevation
import Material.Table as Table
import Set
import Util


view : List PuppetDB.Report.Metric -> Html msg
view metrics =
    Html.div []
        (metricCategories metrics
            |> List.map
                (categoryView metrics)
        )


{-| View for one metric category
-}
categoryView : List PuppetDB.Report.Metric -> String -> Html msg
categoryView metrics category =
    Card.view [ Elevation.e2 ]
        [ Card.title []
            [ Card.head [] [ text category ] ]
        , Card.text []
            [ Table.table []
                [ Table.thead []
                    [ Table.tr []
                        [ Table.th [] [ text "Category" ]
                        , Table.th [] [ text "Count" ]
                        ]
                    ]
                , Table.tbody []
                    ((metricsForCategory category metrics)
                        |> List.map
                            (\metric ->
                                Table.tr []
                                    [ Table.td [] [ text metric.name ]
                                    , Table.td [ Table.numeric ] [ text (Util.roundSignificantFiguresPretty 3 metric.value) ]
                                    ]
                            )
                    )
                ]
            ]
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
    List.foldl
        (\metric filteredMetrics ->
            if metric.category == category then
                List.append filteredMetrics [ metric ]
            else
                filteredMetrics
        )
        []
        metrics


{-| Turn list of metrics to list of data for chart library
-}
metricsToData : List PuppetDB.Report.Metric -> List ( Float, String )
metricsToData metrics =
    List.map
        (\metric ->
            ( metric.value
            , (metric.name ++ " " ++ Util.roundSignificantFiguresPretty 3 metric.value)
            )
        )
        metrics


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
