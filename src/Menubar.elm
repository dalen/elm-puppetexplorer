module Menubar exposing (view)

import Bootstrap.Navbar as Navbar
import FontAwesome.Web as Icon
import Html exposing (Html)
import Route


view : Maybe String -> Route.Route -> (Route.Route -> msg) -> Navbar.State -> (Navbar.State -> msg) -> Html msg
view query route routeMsg menuModel navbarMsg =
    Navbar.config navbarMsg
        |> Navbar.items
            -- Dashboard
            [ let
                itemLink =
                    case route of
                        Route.Dashboard _ ->
                            Navbar.itemLinkActive

                        _ ->
                            Navbar.itemLink
              in
                itemLink (Route.linkAttributes (Route.Dashboard (Route.DashboardParams query)) routeMsg)
                    [ Icon.tachometer, Html.text " ", Html.text "Dashboard" ]

            -- Nodes
            , let
                itemLink =
                    case route of
                        Route.NodeList _ ->
                            Navbar.itemLinkActive

                        _ ->
                            Navbar.itemLink
              in
                itemLink (Route.linkAttributes (Route.NodeList (Route.NodeListParams query)) routeMsg)
                    [ Icon.server, Html.text " ", Html.text "Nodes" ]
            ]
        |> Navbar.view menuModel
