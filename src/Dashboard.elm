module Dashboard exposing (..)

import Material.Grid as Grid
import Dashboard.Panel as Panel
import Html exposing (Html)
import Config
import Route
import Task exposing (Task)
import View.Page as Page
import Page.Errored as Errored exposing (PageLoadError)


type alias Model =
    { panels : DashboardPanels
    }


type alias DashboardPanels =
    List (List Panel.DashboardPanel)


type alias PanelConfigs =
    List (List Config.DashboardPanelConfig)


init : Config.Config -> Route.DashboardParams -> Task PageLoadError Model
init config params =
    let
        handleLoadError _ =
            Errored.pageLoadError Page.Dashboard "Failed to load dashboard."
    in
        Task.map Model (getPanels config.serverUrl config.dashboardPanels)
            |> Task.mapError handleLoadError


getPanels : String -> PanelConfigs -> Task PageLoadError DashboardPanels
getPanels serverUrl panelConfigs =
    List.map (getPanelRow serverUrl) panelConfigs
        |> Task.sequence


getPanelRow : String -> List Config.DashboardPanelConfig -> Task PageLoadError (List Panel.DashboardPanel)
getPanelRow serverUrl panelConfigRow =
    List.map (Panel.get serverUrl) panelConfigRow
        |> Task.sequence


{-| Transform panel matching rowIndex and panelIndex using supplied function
-}
updatePanel : (Panel.DashboardPanel -> Panel.DashboardPanel) -> Int -> Int -> DashboardPanels -> DashboardPanels
updatePanel function rowIndex panelIndex dashboardPanels =
    List.indexedMap
        (\r row ->
            List.indexedMap
                (\p panel ->
                    if rowIndex == r && panelIndex == p then
                        function panel
                    else
                        panel
                )
                row
        )
        dashboardPanels


{-| Render a row of metrics
-}
panelRow : List Panel.DashboardPanel -> Html Never
panelRow panels =
    Grid.grid [] (List.map Panel.view panels)


view : Model -> Html Never
view model =
    Html.div []
        (List.append
            (List.map
                panelRow
                model.panels
            )
            [ usage ]
        )


{-| The usage Instructions
-}
usage : Html Never
usage =
    Grid.grid []
        [ Grid.cell [ Grid.size Grid.All 4 ]
            [ Html.text "test1"
            ]
        , Grid.cell [ Grid.size Grid.All 4 ]
            [ Html.text "test2"
            ]
        , Grid.cell [ Grid.size Grid.All 4 ]
            [ Html.text "test3"
            ]
        ]
