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
import Routing


header : Maybe String -> Model -> Html Msg -> Html Msg
header query model page =
    Html.div []
        [ Search.view query
        , Menubar.view query model.route NewUrlMsg model.menubar NavbarMsg
        , Grid.containerFluid []
            (List.map (\message -> Alert.warning [ Html.text message ]) model.messages)
        , Grid.containerFluid [] [ page ]
        ]


view : Model -> Html Msg
view model =
    case model.route of
        Routing.DashboardRoute query ->
            header query
                model
                (Dashboard.view model)

        Routing.NodeListRoute query ->
            header query
                model
                (Html.map NodeListMsg (NodeList.view model.nodeList query model.date))

        Routing.NodeDetailRoute node page query ->
            header query
                model
                (Html.map NodeDetailMsg (NodeDetail.view model.nodeDetail node page model.date))
