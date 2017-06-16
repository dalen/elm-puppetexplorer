module Dashboard.Panel exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr exposing (attribute, class)
import Config
import PuppetDB.Bean
import Http
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import Task exposing (Task)
import Polymer.Paper as Paper


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
view : DashboardPanel -> Html msg
view panel =
    Html.div [ class "col-xs-12 col-sm-6 col-md4 col-lg-3" ]
        [ Paper.card [ attribute "heading" panel.config.title ]
            [ Html.div [ Attr.class "card-content" ] [ Html.text (toString panel.value) ]
            ]
        ]
