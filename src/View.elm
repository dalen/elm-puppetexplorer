module View exposing (view)

import Html exposing (Html, div, text, program)
import Menubar
import Search
import Types exposing (..)


header : String -> Maybe String -> Model -> Html Msg
header active query model =
    div []
        [ Search.view query model
        , Menubar.view active query model.menubar
        ]


view : Model -> Html Msg
view model =
    case model.route of
        Just (Dashboard query) ->
            div []
                [ header "Dashboard" query model
                , text model.string
                ]

        Just (NodeList query) ->
            div []
                [ header "Nodes" query model
                , text "nodelist"
                ]

        Nothing ->
            div []
                [ header "" Nothing model
                , text "not found"
                ]
