module Menubar exposing (view)

import Bootstrap.Navbar as Navbar
import FontAwesome.Web as Icon
import Html exposing (Html, text)
import Routing


view : Maybe String -> Routing.Route -> (Routing.Route -> msg) -> Navbar.State -> (Navbar.State -> msg) -> Html msg
view query route routeMsg menuModel navbarMsg =
    Navbar.config navbarMsg
        |> Navbar.items
            -- Dashboard
            [ let
                itemLink =
                    case route of
                        Routing.DashboardRoute _ ->
                            Navbar.itemLinkActive

                        _ ->
                            Navbar.itemLink
              in
                itemLink (Routing.linkAttributes (Routing.DashboardRoute (Routing.DashboardRouteParams query)) routeMsg)
                    [ Icon.tachometer, text " ", text "Dashboard" ]

            -- Nodes
            , let
                itemLink =
                    case route of
                        Routing.NodeListRoute _ ->
                            Navbar.itemLinkActive

                        _ ->
                            Navbar.itemLink
              in
                itemLink (Routing.linkAttributes (Routing.NodeListRoute (Routing.NodeListRouteParams query)) routeMsg)
                    [ Icon.server, text " ", text "Nodes" ]
            ]
        |> Navbar.view menuModel
