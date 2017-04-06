module Dashboard exposing (..)

import Bootstrap.Card as Card
import Bootstrap.Grid as Grid
import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import Routing
import Dashboard.Panel


{-| Render a row of metrics
-}
metricRow : List DashboardPanel -> Html Msg
metricRow panels =
    Card.deck (List.map (\panel -> Dashboard.Panel.view panel) panels)


view : Model -> Html Msg
view model =
    div []
        (text
            (Maybe.withDefault "foobar" (Routing.getQueryParam model.route))
            :: List.map (\row -> metricRow row) model.dashboard.panels
        )


{-| The usage Instructions
-}
usage : Html Msg
usage =
    Grid.containerFluid []
        [ Grid.simpleRow
            [ Grid.col []
                [ text "test1"
                ]
            , Grid.col []
                [ text "test2"
                ]
            ]
        ]
