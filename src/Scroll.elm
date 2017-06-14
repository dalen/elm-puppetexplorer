module Scroll exposing (ScrollInfo, onScroll)

import Html
import Json.Decode
import Material.Options exposing (on)


type alias ScrollInfo =
    { scrollHeight : Int
    , scrollTop : Int
    , offsetHeight : Int
    }


onScroll : (ScrollInfo -> value) -> Material.Options.Property c value
onScroll msg =
    on "scroll" (Json.Decode.map msg scrollInfoDecoder)


scrollInfoDecoder : Json.Decode.Decoder ScrollInfo
scrollInfoDecoder =
    Json.Decode.map3 ScrollInfo
        (Json.Decode.at [ "target", "scrollHeight" ] Json.Decode.int)
        (Json.Decode.at [ "target", "scrollTop" ] Json.Decode.int)
        (Json.Decode.at [ "target", "offsetHeight" ] Json.Decode.int)
