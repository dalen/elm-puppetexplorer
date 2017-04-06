module View exposing (view)

import Html exposing (Html, div, text, program)
import Types exposing (..)
import Search
import Menubar
import Dashboard
import Routing


header : Model -> Html Msg -> Html Msg
header model page =
    div []
        [ Search.view (Routing.getQueryParam model.route)
        , Menubar.view model
        , page
        ]


view : Model -> Html Msg
view model =
    case model.route of
        DashboardRoute query ->
            header
                model
                (Dashboard.view model query)

        NodeListRoute query ->
            header model
                (Dashboard.view model query)
