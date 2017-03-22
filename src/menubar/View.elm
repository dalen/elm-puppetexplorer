module Menubar.View exposing (view)

import Bootstrap.Navbar as Navbar
import Html exposing (Html, text)
import Html.Attributes exposing (href)
import Menubar.Types exposing (..)


view : Maybe String -> Model -> Html Msg
view query model =
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
                [ Navbar.itemLink [ href ("/" ++ queryString) ] [ text "Dashboard" ]
                , Navbar.itemLink [ href ("/nodes" ++ queryString) ] [ text "Nodes" ]
                ]
            |> Navbar.view model.navbarState
