module Dashboard exposing (..)

import Bootstrap.Card as Card
import Bootstrap.Grid as Grid
import Dashboard.Panel
import Html exposing (..)
import Types exposing (..)
import List.Extra


init : Config -> Model -> ( Model, Cmd Msg )
init config model =
    ( model
    , Cmd.batch
        (List.indexedMap
            (\rowIndex row ->
                Cmd.batch
                    (List.indexedMap
                        (\panelIndex panel ->
                            Dashboard.Panel.fetch config.serverUrl panel (UpdateDashboardPanel rowIndex panelIndex)
                        )
                        row
                    )
            )
            model.dashboardPanels
        )
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
        (List.append
            (List.map
                (\row -> metricRow row)
                model.dashboardPanels
            )
            [ usage ]
        )


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
            , Grid.col []
                [ text "test3"
                ]
            ]
        ]
