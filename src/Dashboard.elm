module Dashboard exposing (..)

import Bootstrap.Card as Card
import Bootstrap.Grid as Grid
import Dashboard.Panel
import Html exposing (..)
import Dict
import RemoteData exposing (WebData)
import Config


type alias Model =
    { panels : DashboardPanelValues
    }


type Msg
    = UpdateDashboardPanel Int Int (WebData Float)


type alias DashboardPanelValues =
    Dict.Dict ( Int, Int ) (WebData Float)


initModel : Model
initModel =
    { panels = Dict.empty }


load : Config.Config -> Model -> ( Model, Cmd Msg )
load config model =
    ( { model | panels = Dict.empty }
    , Cmd.batch
        (List.indexedMap
            (\rowIndex row ->
                Cmd.batch
                    (List.indexedMap
                        (\panelIndex panel ->
                            Dashboard.Panel.fetch config.serverUrl panel (UpdateDashboardPanel rowIndex panelIndex)
                        )
                        row
                    )
            )
            config.dashboardPanels
        )
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateDashboardPanel rowIndex panelIndex response ->
            ( setPanelMetric response rowIndex panelIndex model, Cmd.none )


setPanelMetric : WebData Float -> Int -> Int -> Model -> Model
setPanelMetric value rowIndex panelIndex model =
    { model | panels = Dict.insert ( rowIndex, panelIndex ) value model.panels }


{-| Render a row of metrics
-}
panelRow : List Dashboard.Panel.DashboardPanel -> Html Msg
panelRow panels =
    Card.deck (List.map (\panel -> Dashboard.Panel.view panel) panels)


{-| Get a list of DashboardPanel instances from DashboardPanelConfigs and values
-}
panels : List (List Config.DashboardPanelConfig) -> DashboardPanelValues -> List (List Dashboard.Panel.DashboardPanel)
panels panelConfigs values =
    (List.indexedMap
        (\rowIndex row ->
            (List.indexedMap
                (\panelIndex panelConfig ->
                    { config = panelConfig
                    , value = Dict.get ( rowIndex, panelIndex ) values
                    }
                )
                row
            )
        )
        panelConfigs
    )



-- FIXME Put panel config into the dashboard state instead and don't pass config here


view : Config.Config -> Model -> Html Msg
view config model =
    div []
        (List.append
            (List.map
                (\row -> panelRow row)
                (panels config.dashboardPanels model.panels)
            )
            [ usage ]
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
            , Grid.col []
                [ text "test3"
                ]
            ]
        ]
