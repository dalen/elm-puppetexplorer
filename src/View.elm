module View exposing (..)

import Html exposing (Html, div, text, program)
import Menubar.View
import Search.View
import Types exposing (..)


view : Model -> Html Msg
view model =
    case model.route of
        Just (Dashboard query) ->
            div []
                [ Search.View.view model.search
                    |> Html.map SearchMsg
                , Menubar.View.view query model.menubar
                    |> Html.map MenubarMsg
                , text model.string
                ]

        Just (NodeList query) ->
            div []
                [ Search.View.view model.search
                    |> Html.map SearchMsg
                , Menubar.View.view query model.menubar
                    |> Html.map MenubarMsg
                , text "nodelist"
                ]

        Nothing ->
            div []
                [ Search.View.view model.search
                    |> Html.map SearchMsg
                , Menubar.View.view Nothing model.menubar
                    |> Html.map MenubarMsg
                , text "not found"
                ]
