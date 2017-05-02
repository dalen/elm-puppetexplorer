module Dashboard exposing (..)

import Bootstrap.Card as Card
import Bootstrap.Grid as Grid
import Dashboard.Panel
import Html exposing (..)
import Types exposing (..)
import Dict
import RemoteData exposing (WebData)


init : Config -> Model -> ( Model, Cmd Msg )
init config model =
    ( { model | dashboardPanels = Dict.empty }
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
            config.dashboardPanels
        )
    )


setPanelMetric : WebData Float -> Int -> Int -> Model -> Model
setPanelMetric value rowIndex panelIndex model =
    { model | dashboardPanels = Dict.insert ( rowIndex, panelIndex ) value model.dashboardPanels }


{-| Render a row of metrics
-}
panelRow : List DashboardPanel -> Html Msg
panelRow panels =
    Card.deck (List.map (\panel -> Dashboard.Panel.view panel) panels)


{-| Get a list of DashboardPanel instances from DashboardPanelConfigs and values
-}
panels : List (List DashboardPanelConfig) -> DashboardPanelValues -> List (List DashboardPanel)
panels panelConfigs values =
    (List.indexedMap
        (\rowIndex row ->
            (List.indexedMap
                (\panelIndex panelConfig ->
                    { config = panelConfig
                    , value = Dict.get ( rowIndex, panelIndex ) values
                    }
                )
                row
            )
        )
        panelConfigs
    )


view : Config -> Model -> Html Msg
view config model =
    div []
        (List.append
            (List.map
                (\row -> panelRow row)
                (panels config.dashboardPanels model.dashboardPanels)
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
