module Menubar exposing (view)

import Bootstrap.Navbar as Navbar
import FontAwesome.Web as Icon
import Html exposing (Html, text)
import Types exposing (..)
import Routing
import Link


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
                itemLink (Link.linkAttributes (DashboardRoute query))
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
                itemLink (Link.linkAttributes (NodeListRoute query))
                    [ Icon.server, text " ", text "Nodes" ]
            ]
        |> Navbar.view menuModel
