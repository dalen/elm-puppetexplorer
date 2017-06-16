module Scroll exposing (ScrollInfo, onScroll)

import Html exposing (Html)
import Html.Events
import Json.Decode


type alias ScrollInfo =
    { scrollHeight : Int
    , scrollTop : Int
    , offsetHeight : Int
    }


onScroll : (ScrollInfo -> msg) -> Html.Attribute msg
onScroll msg =
    Html.Events.on "scroll" (Json.Decode.map msg scrollInfoDecoder)


scrollInfoDecoder : Json.Decode.Decoder ScrollInfo
scrollInfoDecoder =
    Json.Decode.map3 ScrollInfo
        (Json.Decode.at [ "target", "scrollHeight" ] Json.Decode.int)
        (Json.Decode.at [ "target", "scrollTop" ] Json.Decode.int)
        (Json.Decode.at [ "target", "offsetHeight" ] Json.Decode.int)
