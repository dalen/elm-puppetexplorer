module Search.State exposing (..)

import Navigation exposing (Location)
import Search.Types exposing (..)


init : Location -> ( Model, Cmd Msg )
init location =
    ( { query = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateQuery query ->
            ( { model | query = query }, Cmd.none )
