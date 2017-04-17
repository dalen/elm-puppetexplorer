module Dashboard.Panel exposing (..)

import Html exposing (..)
import Types exposing (DashboardPanel, Msg)
import Bootstrap.Card as Card
import FontAwesome.Web as Icon
import PuppetDB
import Http


{-| Return a new empty panel config
-}
new : DashboardPanel
new =
    { title = "", bean = "", style = Card.primary, multiply = Nothing, unit = Nothing, value = Nothing }


title : String -> DashboardPanel -> DashboardPanel
title str panel =
    { panel | title = str }


bean : String -> DashboardPanel -> DashboardPanel
bean str panel =
    { panel | bean = str }


value : Float -> DashboardPanel -> DashboardPanel
value value panel =
    { panel | value = Just value }


fetch : String -> DashboardPanel -> (Result Http.Error Float -> msg) -> Cmd msg
fetch serverUrl panel msg =
    PuppetDB.fetchBean serverUrl panel.bean msg


{-| Render a panel
-}
view : DashboardPanel -> Card.Config Msg
view panel =
    Card.config [ Card.primary ]
        |> Card.headerH4 [] [ text panel.title ]
        |> Card.block []
            [ case panel.value of
                Just value ->
                    Card.text [] [ text (toString value) ]

                Nothing ->
                    Card.text [] [ Icon.spinner ]
            ]