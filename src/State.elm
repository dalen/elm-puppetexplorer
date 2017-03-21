module State exposing (..)

import Menubar.State
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    let
        ( menubarModel, menubarMsg ) =
            Menubar.State.init
    in
        ( { string = "Hello", menubar = menubarModel }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MenubarMsg msg ->
            -- Menubar.State.update model.menubar msg
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
