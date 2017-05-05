module View exposing (view)

import Html exposing (Html)
import Types exposing (..)
import Search
import Menubar
import Dashboard
import NodeList
import NodeDetail
import Bootstrap.Alert as Alert
import Bootstrap.Progress as Progress
import Bootstrap.Grid as Grid
import RemoteData


header : Maybe String -> Model -> Html Msg -> Html Msg
header query model page =
    Html.div []
        [ Search.view query
        , Menubar.view query model.route model.menubar
        , Grid.containerFluid []
            (List.map (\message -> Alert.warning [ Html.text message ]) model.messages)
        , Grid.containerFluid [] [ page ]
        ]


view : Model -> Html Msg
view model =
    case model.config of
        RemoteData.Failure err ->
            -- FIXME: Skip header perhaps?
            header Nothing
                model
                (Progress.progress
                    [ Progress.label ("Failed to load configuration: " ++ (toString err))
                    , Progress.animated
                    , Progress.value 100
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
                (Progress.progress
                    [ Progress.label "Loading configuration..."
                    , Progress.animated
                    ]
                )
