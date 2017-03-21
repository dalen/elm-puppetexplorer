module Search.State exposing (..)

import Search.Types exposing (..)


init : ( Model, Cmd Msg )
init =
    ( { query = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateQuery query ->
            ( { model | query = query }, Cmd.none )
