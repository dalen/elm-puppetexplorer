module View exposing (view)

import Html exposing (Html, div, text, program)
import Html.Attributes exposing (class)
import Types exposing (..)
import Search
import Menubar
import Dashboard
import Routing
import Bootstrap.Alert
import Bootstrap.Progress


header : Model -> Html Msg -> Html Msg
header model page =
    div []
        [ Search.view (Routing.getQueryParam model.route)
        , Menubar.view model
        , div [ class "container-fluid" ]
            (List.map (\message -> Bootstrap.Alert.warning [ text message ]) model.messages)
        , div [ class "container-fluid" ] [ page ]
        ]


view : Model -> Html Msg
view model =
    case model.config of
        Nothing ->
            header model
                (Bootstrap.Progress.progress
                    [ Bootstrap.Progress.label "Loading configuration..."
                    , Bootstrap.Progress.animated
                    ]
                )

        Just config ->
            case model.route of
                DashboardRoute query ->
                    header
                        model
                        (Dashboard.view model)

                NodeListRoute query ->
                    header model
                        (text "nodelist")
