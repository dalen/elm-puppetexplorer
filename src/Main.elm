module Main exposing (..)

import Html exposing (Html, div, text, program)
import Menubar.View
import Menubar.Types
import Menubar.State


-- MODEL


type alias Model =
    { string : String
    , menubar : Menubar.Types.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( menubarModel, menubarMsg ) =
            Menubar.State.init
    in
        ( { string = "Hello", menubar = menubarModel }, Cmd.none )



-- MESSAGES


type Msg
    = MenubarMsg Menubar.Types.Msg
    | NoOp



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Menubar.View.view model.menubar
            |> Html.map MenubarMsg
        , text model.string
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MenubarMsg msg ->
            -- Menubar.State.update model.menubar msg
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
