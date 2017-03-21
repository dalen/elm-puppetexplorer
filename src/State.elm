module State exposing (..)

import Menubar.State
import Search.State
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    let
        ( menubarModel, menubarMsg ) =
            Menubar.State.init

        ( searchModel, searchMsg ) =
            Search.State.init
    in
        ( { string = "Hello"
          , menubar = menubarModel
          , search = searchModel
          }
        , Cmd.none
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
