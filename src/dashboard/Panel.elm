module Dashboard.Panel exposing (..)

import Html exposing (Html, text)
import Config
import PuppetDB.Bean
import Http
import Page.Errored as Errored exposing (ErrorMessage)
import Task exposing (Task)
import Material.Card as Card
import Material.Grid as Grid
import Material.Options as Options
import Material.Typography as Typography
import Material.Color as Color
import Material.Elevation as Elevation


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


get : String -> Config.DashboardPanelConfig -> Task ErrorMessage DashboardPanel
get serverUrl config =
    PuppetDB.Bean.get serverUrl config.bean
        |> Http.toTask
        |> Task.mapError (Errored.httpError config.title)
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
    Grid.cell [ Grid.size Grid.All 4 ]
        [ Card.view [ Elevation.e2 ]
            [ Card.title []
                [ Card.head [] [ text panel.config.title ]
                ]
            , Card.text []
                [ Options.span
                    [ Typography.display4
                    , Color.text Color.primary
                    ]
                    [ text (toString panel.value) ]
                ]
            ]
        ]
