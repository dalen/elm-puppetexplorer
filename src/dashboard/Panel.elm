module Dashboard.Panel exposing (..)

import Html
import Html.Attributes
import Types exposing (DashboardPanel, DashboardPanelConfig, Msg)
import Bootstrap.Card as Card
import FontAwesome.Web as Icon
import PuppetDB
import RemoteData exposing (WebData)


{-| Return a new empty panel config
-}
new : DashboardPanelConfig
new =
    { title = "", bean = "", style = Card.primary, multiply = Nothing, unit = Nothing, value = Nothing }


title : String -> DashboardPanelConfig -> DashboardPanelConfig
title str panel =
    { panel | title = str }


bean : String -> DashboardPanelConfig -> DashboardPanelConfig
bean str panel =
    { panel | bean = str }


value : Float -> DashboardPanelConfig -> DashboardPanelConfig
value value panel =
    { panel | value = Just value }


fetch : String -> DashboardPanelConfig -> (WebData Float -> msg) -> Cmd msg
fetch serverUrl panel msg =
    PuppetDB.fetchBean serverUrl panel.bean msg


{-| Render a panel
-}
view : DashboardPanel -> Card.Config Msg
view panel =
    Card.config [ panel.config.style ]
        |> Card.headerH4 [] [ Html.text panel.config.title ]
        |> Card.block []
            [ case panel.value of
                Just (RemoteData.Success value) ->
                    Card.text [] [ Html.text (toString value) ]

                Just RemoteData.Loading ->
                    Card.text [] [ Icon.spinner ]

                Just (RemoteData.Failure err) ->
                    Card.text [ Html.Attributes.title (toString err) ] [ Icon.exclamation_circle ]

                _ ->
                    Card.text [] []
            ]
