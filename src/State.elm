module State exposing (..)

import Navigation exposing (Location)
import Debug exposing (log)
import Menubar.State
import Search.State
import Types exposing (..)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( menubarModel, menubarMsg ) =
            Menubar.State.init location

        ( searchModel, searchMsg ) =
            Search.State.init location
    in
        ( { string = "Hello"
          , menubar = menubarModel
          , search = searchModel
          }
        , Cmd.none
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "update" ( msg, model )
    in
        case msg of
            MenubarMsg msg ->
                let
                    ( menubarModel, cmd ) =
                        Menubar.State.update msg model.menubar
                in
                    ( { model | menubar = menubarModel }, Cmd.map MenubarMsg cmd )

            SearchMsg msg ->
                let
                    ( searchModel, cmd ) =
                        Search.State.update msg model.search
                in
                    ( { model | search = searchModel }, Cmd.map SearchMsg cmd )

            LocationChange location ->
                ( model, Cmd.none )

            NoOp ->
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
