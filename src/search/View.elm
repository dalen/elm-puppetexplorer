module Search.View exposing (view)

import Bootstrap.Form.Input as Input
import Html exposing (Html)
import Search.Types exposing (..)


view : Model -> Html Msg
view model =
    Input.search
        [ Input.id "myinput"
        , Input.defaultValue model.query
        , Input.onInput UpdateQuery
        ]
