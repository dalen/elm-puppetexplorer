module Dashboard exposing (..)

import Html exposing (..)
import Types exposing (..)
import Navigation exposing (Location)


view : Model -> Maybe String -> Html Msg
view model query =
    text (Maybe.withDefault "foobar" query)
