module Dashboard exposing (..)

import Bootstrap.Card as Card
import Bootstrap.Grid as Grid
import Dashboard.Panel
import Html exposing (..)
import Http
import Types exposing (..)
import List.Extra


getPanelMetric : Int -> Int -> DashboardPanel -> Cmd Msg
getPanelMetric row index panel =
    let
        url =
            "/api/metrics/v1/mbeans/" ++ panel.bean
    in
        Http.send (UpdateDashboardPanel row index) (Http.get url Dashboard.Panel.decoder)


getPanelMetrics : Model -> Cmd Msg
getPanelMetrics model =
    Cmd.batch
        (List.indexedMap
            (\rowIndex row ->
                Cmd.batch
                    (List.indexedMap
                        (\panelIndex panel ->
                            getPanelMetric rowIndex panelIndex panel
                        )
                        row
                    )
            )
            model.dashboardPanels
        )


setPanelMetric : Float -> Int -> Int -> Model -> Model
setPanelMetric value rowIndex panelIndex model =
    { model
        | dashboardPanels =
            Maybe.withDefault model.dashboardPanels
                (List.Extra.updateAt rowIndex
                    (\row ->
                        Maybe.withDefault row
                            (List.Extra.updateAt panelIndex
                                (\panel ->
                                    { panel | value = Just value }
                                )
                                row
                            )
                    )
                    model.dashboardPanels
                )
    }


{-| Render a row of metrics
-}
metricRow : List DashboardPanel -> Html Msg
metricRow panels =
    Card.deck (List.map (\panel -> Dashboard.Panel.view panel) panels)


view : Model -> Html Msg
view model =
    div []
        (List.map (\row -> metricRow row) model.dashboardPanels)


{-| The usage Instructions
-}
usage : Html Msg
usage =
    Grid.containerFluid []
        [ Grid.simpleRow
            [ Grid.col []
                [ text "test1"
                ]
            , Grid.col []
                [ text "test2"
                ]
            ]
        ]
