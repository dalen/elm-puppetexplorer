module View exposing (view)

import Html exposing (Html, div, text, program)
import Html.Attributes exposing (class)
import Types exposing (..)
import Search
import Menubar
import Dashboard
import NodeList
import Routing
import Bootstrap.Alert
import Bootstrap.Progress
import RemoteData


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
        RemoteData.Failure err ->
            header model
                (Bootstrap.Progress.progress
                    [ Bootstrap.Progress.label ("Failed to load configuration: " ++ (toString err))
                    , Bootstrap.Progress.animated
                    ]
                )

        RemoteData.Success config ->
            case model.route of
                DashboardRoute query ->
                    header
                        model
                        (Dashboard.view config model)

                NodeListRoute query ->
                    header model
                        (NodeList.view config model)

        _ ->
            header model
                (Bootstrap.Progress.progress
                    [ Bootstrap.Progress.label "Loading configuration..."
                    , Bootstrap.Progress.animated
                    ]
                )
