module Dashboard.Panel exposing (..)

import Html exposing (Html, text)
import Config
import PuppetDB.Bean
import Http
import Page.Errored as Errored exposing (ErrorMessage)
import Task exposing (Task)
import Bootstrap.Card as Card
import Bootstrap.Grid as Grid


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
view : DashboardPanel -> Grid.Column msg
view panel =
    Grid.col []
        [ Card.config []
            |> Card.header [] [ text panel.config.title ]
            |> Card.block []
                [ Card.text
                    []
                    [ text (toString panel.value) ]
                ]
            |> Card.view
        ]
