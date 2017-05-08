module View exposing (view)

import Html exposing (Html)
import Types exposing (..)
import Search
import Menubar
import Dashboard
import NodeList
import NodeDetail
import Bootstrap.Alert as Alert
import Bootstrap.Grid as Grid


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
    case model.route of
        DashboardRoute query ->
            header query
                model
                (Dashboard.view model)

        NodeListRoute query ->
            header query
                model
                (NodeList.view model query)

        NodeDetailRoute node page query ->
            header query
                model
                (Html.map NodeDetailMsg (NodeDetail.view model.nodeDetail node page model.date))
