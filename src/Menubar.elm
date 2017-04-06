module Menubar exposing (view)

import Bootstrap.Navbar as Navbar
import FontAwesome.Web as Icon
import Html exposing (Html, text)
import Html.Attributes exposing (href)
import Types exposing (..)
import Events
import Routing


{-| List of attributes for a link that has a href and an onClick handler
    that creates a NewUrl message
-}
eventLink : Route -> List (Html.Attribute Msg)
eventLink route =
    [ href (Routing.toString route)
    , (Events.onClickPreventDefault (NewUrlMsg route))
    ]


view : Model -> Html Msg
view model =
    Navbar.config NavbarMsg
        |> Navbar.items
            -- Dashboard
            [ let
                itemLink =
                    case model.route of
                        DashboardRoute _ ->
                            Navbar.itemLinkActive

                        _ ->
                            Navbar.itemLink
              in
                itemLink (eventLink (DashboardRoute (Routing.getQueryParam model.route)))
                    [ Icon.tachometer, text " ", text "Dashboard" ]

            -- Nodes
            , let
                itemLink =
                    case model.route of
                        NodeListRoute _ ->
                            Navbar.itemLinkActive

                        _ ->
                            Navbar.itemLink
              in
                itemLink (eventLink (NodeListRoute (Routing.getQueryParam model.route)))
                    [ Icon.server, text " ", text "Nodes" ]
            ]
        |> Navbar.view model.menubar
