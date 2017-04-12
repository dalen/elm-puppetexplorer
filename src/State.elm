module State exposing (..)

import Navigation exposing (Location)
import Debug exposing (log)
import Types exposing (..)
import Bootstrap.Navbar
import Routing
import Dashboard
import Dashboard.Panel


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( navbarState, navbarCmd ) =
            Bootstrap.Navbar.initialState NavbarMsg

        ( route, routeMsg ) =
            Routing.init location
    in
        ( { string = "Hello"
          , menubar = navbarState
          , route = route
          , dashboardPanels =
                [ [ Dashboard.Panel.new
                        |> Dashboard.Panel.title "Nodes"
                        |> Dashboard.Panel.bean "puppetlabs.puppetdb.population:name=num-nodes"
                  , Dashboard.Panel.new
                        |> Dashboard.Panel.title "Resources"
                        |> Dashboard.Panel.bean "puppetlabs.puppetdb.population:name=num-resources"
                  ]
                ]
          }
        , navbarCmd
        )
            |> andThen (update routeMsg)


noCmd : Model -> ( Model, Cmd Msg )
noCmd model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "update" ( msg, model )
    in
        case msg of
            NavbarMsg state ->
                ( { model | menubar = state }, Cmd.none )

            UpdateQueryMsg query ->
                case model.route of
                    DashboardRoute _ ->
                        ( model, Navigation.newUrl (Routing.toString (DashboardRoute (Just query))) )

                    NodeListRoute _ ->
                        ( model, Navigation.newUrl (Routing.toString (NodeListRoute (Just query))) )

            NewUrlMsg route ->
                ( model, Navigation.newUrl (Routing.toString route) )

            LocationChangeMsg location ->
                let
                    ( route, routeMsg ) =
                        Routing.init location
                in
                    update routeMsg { model | route = route }

            FetchDashboardPanels ->
                ( model, Dashboard.getPanelMetrics model )

            UpdateDashboardPanel rowIndex panelIndex (Ok value) ->
                ( Dashboard.setPanelMetric value rowIndex panelIndex model, Cmd.none )

            UpdateDashboardPanel _ _ (Err _) ->
                ( model, Cmd.none )

            NoOpMsg ->
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Bootstrap.Navbar.subscriptions model.menubar NavbarMsg


andThen : (Model -> ( Model, Cmd msg )) -> ( Model, Cmd msg ) -> ( Model, Cmd msg )
andThen advance ( beginModel, cmd1 ) =
    let
        ( newModel, cmd2 ) =
            advance beginModel
    in
        ( newModel, Cmd.batch [ cmd1, cmd2 ] )
