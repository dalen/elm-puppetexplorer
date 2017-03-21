module Menubar.View exposing (view)

import Bootstrap.Navbar as Navbar
import Html exposing (Html, text)
import Html.Attributes exposing (href)
import Menubar.Types exposing (..)


view : Model -> Html Msg
view model =
    Navbar.config NavbarMsg
        |> Navbar.withAnimation
        |> Navbar.brand [ href "#" ] [ text "Brand" ]
        |> Navbar.items
            [ Navbar.itemLink [ href "#" ] [ text "Item 1" ]
            , Navbar.itemLink [ href "#" ] [ text "Item 2" ]
            ]
        |> Navbar.view model.navbarState
