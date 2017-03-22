module Events exposing (..)

import Html
import Html.Events exposing (on, onWithOptions, targetValue)
import Json.Decode as Json


preventDefaultOptions : Html.Events.Options
preventDefaultOptions =
    { preventDefault = True, stopPropagation = True }


onChange : (String -> msg) -> Html.Attribute msg
onChange msg =
    on "change" (Json.map msg targetValue)


onClickPreventDefault : msg -> Html.Attribute msg
onClickPreventDefault msg =
    onWithOptions "click" preventDefaultOptions (Json.succeed msg)
