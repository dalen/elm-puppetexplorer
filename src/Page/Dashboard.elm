module Page.Dashboard exposing (..)

import Dashboard.Panel as Panel
import Html exposing (Html, text)
import Html.Attributes as Attr
import Config
import Task exposing (Task)
import View.Page as Page
import Page.Errored as Errored exposing (PageLoadError, ErrorMessage)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row


type alias Model =
    { panels : DashboardPanels
    }


type alias DashboardPanels =
    List (List Panel.DashboardPanel)


type alias PanelConfigs =
    List (List Config.DashboardPanelConfig)


init : Config.Config -> Task PageLoadError Model
init config =
    Task.map Model (getPanels config.serverUrl config.dashboardPanels)
        |> Task.mapError (Errored.pageLoadError Page.Dashboard)


getPanels : String -> PanelConfigs -> Task ErrorMessage DashboardPanels
getPanels serverUrl panelConfigs =
    List.map (getPanelRow serverUrl) panelConfigs
        |> Task.sequence


getPanelRow : String -> List Config.DashboardPanelConfig -> Task ErrorMessage (List Panel.DashboardPanel)
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
    Grid.row [ Row.attrs [ Attr.class "py-2" ] ] (List.map Panel.view panels)


view : Model -> Html Never
view model =
    Grid.container [ Attr.class "py-2" ]
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
    text "Usage instructions"
