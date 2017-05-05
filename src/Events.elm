module Events exposing (..)

import Html
import Html.Events exposing (on, onWithOptions, targetValue, defaultOptions)
import Json.Decode


onChange : (String -> msg) -> Html.Attribute msg
onChange msg =
    on "change" (Json.Decode.map msg targetValue)


onClickPreventDefault : msg -> Html.Attribute msg
onClickPreventDefault message =
    onWithOptions "click"
        { defaultOptions | preventDefault = True }
        (preventDefault2
            |> Json.Decode.andThen (maybePreventDefault message)
        )


preventDefault2 : Json.Decode.Decoder Bool
preventDefault2 =
    Json.Decode.map2
        (invertedOr)
        (Json.Decode.field "ctrlKey" Json.Decode.bool)
        (Json.Decode.field "metaKey" Json.Decode.bool)


maybePreventDefault : msg -> Bool -> Json.Decode.Decoder msg
maybePreventDefault msg preventDefault =
    case preventDefault of
        True ->
            Json.Decode.succeed msg

        False ->
            Json.Decode.fail "Normal link"


invertedOr : Bool -> Bool -> Bool
invertedOr x y =
    not (x || y)
