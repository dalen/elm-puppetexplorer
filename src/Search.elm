module Search exposing (view)

import Bootstrap.Form.Input as Input
import FontAwesome.Web as Icon
import Html exposing (Html, div, span)
import Html.Attributes exposing (class)
import Types exposing (..)
import Events exposing (onChange)


view : Maybe String -> Html Msg
view query =
    div [ class "input-group" ]
        [ span [ class "input-group-addon" ] [ Icon.search ]
        , Input.search
            [ Input.value (Maybe.withDefault "" query)
            , Input.attrs [ onChange UpdateQueryMsg ]
            ]
        ]
