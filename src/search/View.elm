module Search.View exposing (view)

import Html exposing (Html, div, span)
import Html.Attributes exposing (class)
import Bootstrap.Form.Input as Input
import FontAwesome.Web as Icon
import Search.Types exposing (..)


view : Model -> Html Msg
view model =
    div [ class "input-group" ]
        [ span [ class "input-group-addon" ] [ Icon.search ]
        , Input.search
            [ Input.id "myinput"
            , Input.defaultValue model.query
            , Input.onInput UpdateQuery
            ]
        ]
