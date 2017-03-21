module View exposing (..)

import Html exposing (Html, div, text, program)
import Menubar.View
import Search.View
import Types exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ Search.View.view model.search
            |> Html.map SearchMsg
        , Menubar.View.view
            model.menubar
            |> Html.map MenubarMsg
        , text model.string
        ]
