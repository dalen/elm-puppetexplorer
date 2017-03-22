module Menubar exposing (view)

import Bootstrap.Navbar as Navbar
import Html exposing (Html, text)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Types exposing (..)
import Events


navLink : String -> String -> String -> String -> Navbar.Item Msg
navLink name active url queryString =
    let
        attributes =
            [ href (url ++ queryString), (Events.onClickPreventDefault (NewUrl (url ++ queryString))) ]
    in
        if name == active then
            Navbar.itemLink
                attributes
                [ text name ]
        else
            Navbar.itemLinkActive
                attributes
                [ text name ]


view : String -> Maybe String -> Navbar.State -> Html Msg
view active query navbarState =
    let
        queryString =
            case query of
                Just str ->
                    "?query=" ++ str

                Nothing ->
                    ""
    in
        Navbar.config NavbarMsg
            |> Navbar.items
                [ navLink "Dashboard" active "/" queryString
                , navLink "Nodes" active "/nodes" queryString
                ]
            |> Navbar.view navbarState
