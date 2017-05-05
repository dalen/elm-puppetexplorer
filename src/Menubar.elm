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


view : Maybe String -> Route -> Navbar.State -> Html Msg
view query route menuModel =
    Navbar.config NavbarMsg
        |> Navbar.items
            -- Dashboard
            [ let
                itemLink =
                    case route of
                        DashboardRoute _ ->
                            Navbar.itemLinkActive

                        _ ->
                            Navbar.itemLink
              in
                itemLink (eventLink (DashboardRoute query))
                    [ Icon.tachometer, text " ", text "Dashboard" ]

            -- Nodes
            , let
                itemLink =
                    case route of
                        NodeListRoute _ ->
                            Navbar.itemLinkActive

                        _ ->
                            Navbar.itemLink
              in
                itemLink (eventLink (NodeListRoute query))
                    [ Icon.server, text " ", text "Nodes" ]
            ]
        |> Navbar.view menuModel
