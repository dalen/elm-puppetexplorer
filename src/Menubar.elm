module Menubar exposing (view)

import Bootstrap.Navbar as Navbar
import FontAwesome.Web as Icon
import Html exposing (Html, text)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Types exposing (..)
import Events


{-| List of attributes for a link that has a href and an onClick handler
    that creates a NewUrl message
-}
eventLink : String -> List (Html.Attribute Msg)
eventLink url =
    [ href url
    , (Events.onClickPreventDefault (NewUrl url))
    ]


navLink : String -> String -> String -> String -> Navbar.Item Msg
navLink name active url queryString =
    let
        attributes =
            eventLink (url ++ queryString)
    in
        if name == active then
            Navbar.itemLink
                attributes
                [ Icon.tachometer, text " ", text name ]
        else
            Navbar.itemLinkActive
                attributes
                [ Icon.tachometer, text " ", text name ]


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
