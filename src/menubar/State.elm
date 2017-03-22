module Menubar.State exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar as Navbar
import Menubar.Types exposing (..)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg
    in
        ( { navbarState = navbarState }, navbarCmd )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navbarState NavbarMsg
