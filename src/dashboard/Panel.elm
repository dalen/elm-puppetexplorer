module Dashboard.Panel exposing (..)

import Html
import Config
import Bootstrap.Card as Card
import PuppetDB
import RemoteData exposing (WebData)
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


fetch : String -> Config.DashboardPanelConfig -> (WebData Float -> msg) -> Cmd msg
fetch serverUrl panel msg =
    PuppetDB.fetchBean serverUrl panel.bean msg


get : String -> Config.DashboardPanelConfig -> Task PageLoadError DashboardPanel
get serverUrl config =
    PuppetDB.Bean.get serverUrl config.bean
        |> Http.toTask
        |> Task.mapError (\_ -> Errored.pageLoadError Page.Dashboard "Article is currently unavailable.")
        |> Task.map (fromConfig config)


panelStyle : String -> Card.CardOption msg
panelStyle styleString =
    case styleString of
        "primary" ->
            Card.primary

        _ ->
            Card.primary


{-| Render a panel
-}
view : DashboardPanel -> Card.Config msg
view panel =
    Card.config [ panelStyle panel.config.style ]
        |> Card.headerH4 [] [ Html.text panel.config.title ]
        |> Card.block []
            [ Card.text [] [ Html.text (toString panel.value) ]
            ]
