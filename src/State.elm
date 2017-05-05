module State exposing (..)

import Navigation exposing (Location)
import Debug exposing (log)
import Types exposing (..)
import Bootstrap.Navbar
import Routing
import Dashboard
import NodeList
import NodeDetail
import Config
import Dict
import RemoteData
import Time
import Date
import Date.Extra


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( navbarState, navbarCmd ) =
            Bootstrap.Navbar.initialState NavbarMsg

        route =
            Routing.parse location
    in
        ( { config = RemoteData.NotAsked
          , messages = []
          , menubar = navbarState
          , route = route
          , dashboardPanels = Dict.empty
          , nodeList = RemoteData.NotAsked
          , nodeReportList = RemoteData.NotAsked
          , date = Date.Extra.fromCalendarDate 2017 Date.Jan 1
          }
        , Cmd.batch [ Config.fetch, navbarCmd ]
        )


{-| Initialize the current route
Can update (initialize) the model for the route as well
-}
initRoute : Route -> Config -> Model -> ( Model, Cmd Msg )
initRoute route config model =
    case route of
        DashboardRoute _ ->
            Dashboard.init config model

        NodeListRoute query ->
            NodeList.init config model

        NodeDetailRoute node query ->
            NodeDetail.init config node model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "update" ( msg, model )
    in
        case msg of
            NavbarMsg state ->
                ( { model | menubar = state }, Cmd.none )

            UpdateConfigMsg response ->
                let
                    configModel =
                        { model | config = response }
                in
                    case response of
                        RemoteData.Success config ->
                            initRoute model.route config configModel

                        RemoteData.Failure _ ->
                            ( configModel, Config.fetch )

                        _ ->
                            ( configModel, Cmd.none )

            UpdateQueryMsg query ->
                case model.route of
                    DashboardRoute _ ->
                        ( model, Navigation.newUrl (Routing.toString (DashboardRoute (Just query))) )

                    NodeListRoute _ ->
                        ( model, Navigation.newUrl (Routing.toString (NodeListRoute (Just query))) )

                    NodeDetailRoute node _ ->
                        ( model, Navigation.newUrl (Routing.toString (NodeDetailRoute node (Just query))) )

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
                        RemoteData.Success config ->
                            initRoute route config routeModel

                        _ ->
                            ( routeModel, Cmd.none )

            UpdateDashboardPanel rowIndex panelIndex response ->
                ( Dashboard.setPanelMetric response rowIndex panelIndex model, Cmd.none )

            UpdateNodeListMsg response ->
                ( { model | nodeList = response }, Cmd.none )

            TimeMsg time ->
                ( { model | date = Date.fromTime time }, Cmd.none )

            NoopMsg ->
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Bootstrap.Navbar.subscriptions model.menubar NavbarMsg
        , Time.every Time.second TimeMsg
        ]


andThen : (Model -> ( Model, Cmd msg )) -> ( Model, Cmd msg ) -> ( Model, Cmd msg )
andThen advance ( beginModel, cmd1 ) =
    let
        ( newModel, cmd2 ) =
            advance beginModel
    in
        ( newModel, Cmd.batch [ cmd1, cmd2 ] )
