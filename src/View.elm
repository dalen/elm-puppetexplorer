module View exposing (view)

import Html exposing (Html, div, text, program)
import Html.Attributes exposing (class)
import Types exposing (..)
import Search
import Menubar
import Dashboard
import NodeList
import NodeDetail
import Bootstrap.Alert
import Bootstrap.Progress
import RemoteData


header : Maybe String -> Model -> Html Msg -> Html Msg
header query model page =
    div []
        [ Search.view query
        , Menubar.view query model.route model.menubar
        , div [ class "container-fluid" ]
            (List.map (\message -> Bootstrap.Alert.warning [ text message ]) model.messages)
        , div [ class "container-fluid" ] [ page ]
        ]


view : Model -> Html Msg
view model =
    case model.config of
        RemoteData.Failure err ->
            -- FIXME: Skip header perhaps?
            header Nothing
                model
                (Bootstrap.Progress.progress
                    [ Bootstrap.Progress.label ("Failed to load configuration: " ++ (toString err))
                    , Bootstrap.Progress.animated
                    , Bootstrap.Progress.value 100
                    ]
                )

        RemoteData.Success config ->
            case model.route of
                DashboardRoute query ->
                    header query
                        model
                        (Dashboard.view config model)

                NodeListRoute query ->
                    header query
                        model
                        (NodeList.view config query model)

                NodeDetailRoute node query ->
                    header query
                        model
                        (NodeDetail.view config node model)

        _ ->
            -- FIXME: Skip header perhaps?
            header Nothing
                model
                (Bootstrap.Progress.progress
                    [ Bootstrap.Progress.label "Loading configuration..."
                    , Bootstrap.Progress.animated
                    ]
                )
