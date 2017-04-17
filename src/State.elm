module State exposing (..)

import Navigation exposing (Location)
import Debug exposing (log)
import Types exposing (..)
import Bootstrap.Navbar
import Routing
import Dashboard
import Dashboard.Panel
import Config
import Dict


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( navbarState, navbarCmd ) =
            Bootstrap.Navbar.initialState NavbarMsg

        route =
            Routing.parse location
    in
        ( { config = Nothing
          , messages = []
          , menubar = navbarState
          , route = route
          , dashboardPanels = Dict.empty
          }
        , Cmd.batch [ Config.fetch, navbarCmd ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "update" ( msg, model )
    in
        case msg of
            NavbarMsg state ->
                ( { model | menubar = state }, Cmd.none )

            UpdateConfigMsg (Ok config) ->
                let
                    ( routeModel, routeCmd ) =
                        Routing.init model.route config model
                in
                    ( { routeModel | config = Just config }, routeCmd )

            UpdateConfigMsg (Err _) ->
                ( { model | messages = "Failed to fetch configuration, retrying" :: model.messages }
                , Config.fetch
                )

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
                    route =
                        Routing.parse location

                    routeModel =
                        { model | route = route }
                in
                    case model.config of
                        Nothing ->
                            ( routeModel, Cmd.none )

                        Just config ->
                            Routing.init route config routeModel

            UpdateDashboardPanel rowIndex panelIndex (Ok value) ->
                ( Dashboard.setPanelMetric value rowIndex panelIndex model, Cmd.none )

            UpdateDashboardPanel _ _ (Err _) ->
                ( model, Cmd.none )

            NoopMsg ->
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
