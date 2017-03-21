module View exposing (..)

import Html exposing (Html, div, text, program)
import Menubar.View
import Types exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ Menubar.View.view model.menubar
            |> Html.map MenubarMsg
        , text model.string
        ]
