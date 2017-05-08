module State exposing (..)

import Navigation exposing (Location)
import Debug exposing (log)
import Types exposing (..)
import Bootstrap.Navbar
import Routing
import Dashboard
import NodeList
import NodeDetail
import Dict
import RemoteData
import Time
import Date
import Date.Extra


init : Config -> Location -> ( Model, Cmd Msg )
init config location =
    let
        ( navbarState, navbarCmd ) =
            Bootstrap.Navbar.initialState NavbarMsg

        route =
            Routing.parse location

        ( model, routeCmd ) =
            initRoute route
                { config = config
                , messages = []
                , menubar = navbarState
                , route = route
                , dashboardPanels = Dict.empty
                , nodeList = RemoteData.NotAsked
                , nodeReportList = RemoteData.NotAsked
                , date = Date.Extra.fromCalendarDate 2017 Date.Jan 1
                }
    in
        ( model
        , Cmd.batch [ routeCmd, navbarCmd ]
        )


{-| Initialize the current route
Can update (initialize) the model for the route as well
-}
initRoute : Route -> Model -> ( Model, Cmd Msg )
initRoute route model =
    case route of
        DashboardRoute _ ->
            Dashboard.init model

        NodeListRoute query ->
            NodeList.init model query

        NodeDetailRoute node page query ->
            NodeDetail.init model node page


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            case msg of
                TimeMsg _ ->
                    msg

                _ ->
                    Debug.log "update" msg
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

                    NodeDetailRoute node page _ ->
                        ( model, Navigation.newUrl (Routing.toString (NodeDetailRoute node page (Just query))) )

            NewUrlMsg route ->
                ( model, Navigation.newUrl (Routing.toString route) )

            LocationChangeMsg location ->
                let
                    route =
                        Routing.parse location

                    routeModel =
                        { model | route = route }
                in
                    initRoute route routeModel

            UpdateDashboardPanel rowIndex panelIndex response ->
                ( Dashboard.setPanelMetric response rowIndex panelIndex model, Cmd.none )

            UpdateNodeListMsg response ->
                ( { model | nodeList = response }, Cmd.none )

            UpdateNodeReportListMsg response ->
                ( { model | nodeReportList = response }, Cmd.none )

            UpdateNodeReportListCountMsg response ->
                ( model, Cmd.none )

            ChangePageMsg page ->
                ( model, Cmd.none )

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
