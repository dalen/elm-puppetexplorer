module Link exposing (..)

import Types exposing (..)
import Html
import Html.Attributes
import Events
import Routing


-- FIXME: move this to Routing


link : Route -> List (Html.Html Msg) -> Html.Html Msg
link route =
    Html.a (linkAttributes route)


{-| List of attributes for a link that has a href and an onClick handler
that creates a NewUrl message
-}
linkAttributes : Route -> List (Html.Attribute Msg)
linkAttributes route =
    [ Html.Attributes.href (Routing.toString route)
    , (Events.onClickPreventDefault (NewUrlMsg route))
    ]
