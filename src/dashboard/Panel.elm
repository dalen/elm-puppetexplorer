module Dashboard.Panel exposing (..)

import Html
import Config
import Material.Grid as Grid
import Material.Card as Card
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Options as Options
import Material.Typography as Typography
import PuppetDB.Bean
import Http
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import Task exposing (Task)


type alias DashboardPanel =
    { config : Config.DashboardPanelConfig
    , value : Float
    }


{-| Return a new empty panel config
-}
new : Config.DashboardPanelConfig
new =
    { title = "", bean = "", style = "primary", multiply = Nothing, unit = Nothing }


fromConfig : Config.DashboardPanelConfig -> Float -> DashboardPanel
fromConfig config value =
    { config = config, value = value }


title : String -> Config.DashboardPanelConfig -> Config.DashboardPanelConfig
title str panel =
    { panel | title = str }


bean : String -> Config.DashboardPanelConfig -> Config.DashboardPanelConfig
bean str panel =
    { panel | bean = str }


value : DashboardPanel -> Float -> DashboardPanel
value panel value =
    { panel | value = value }


get : String -> Config.DashboardPanelConfig -> Task PageLoadError DashboardPanel
get serverUrl config =
    PuppetDB.Bean.get serverUrl config.bean
        |> Http.toTask
        |> Task.mapError (Errored.httpError Page.Dashboard config.title)
        |> Task.map (fromConfig config)



{-
   panelStyle : String -> Card.CardOption msg
   panelStyle styleString =
       case styleString of
           "primary" ->
               Card.primary

           _ ->
               Card.primary
-}


{-| Render a panel
-}
view : DashboardPanel -> Grid.Cell msg
view panel =
    Grid.cell [ Grid.size Grid.All 3 ]
        [ Card.view [ Elevation.e2, Options.css "width" "100%" ]
            [ Card.title [] [ Card.head [] [ Html.text panel.config.title ] ]
            , Card.text [ Card.expand, Color.text Color.accent, Typography.center ]
                [ Options.span [ Typography.display3 ] [ Html.text (toString panel.value) ] ]
            ]
        ]
