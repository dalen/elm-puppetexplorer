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
import Config exposing (Config)


init : Config -> Location -> ( Model, Cmd Msg )
init config location =
    let
        ( navbarState, navbarCmd ) =
            Bootstrap.Navbar.initialState NavbarMsg

        route =
            Routing.parse location

        ( nodeDetailModel, nodeDetailCmd ) =
            NodeDetail.init

        ( nodeListModel, nodeListCmd ) =
            NodeList.init

        ( model, routeCmd ) =
            initRoute route
                { config = config
                , messages = []
                , menubar = navbarState
                , route = route
                , dashboardPanels = Dict.empty
                , nodeList = nodeListModel
                , nodeDetail = nodeDetailModel
                , date = Date.Extra.fromCalendarDate 2017 Date.Jan 1
                }
    in
        ( model
        , Cmd.batch
            [ routeCmd
            , navbarCmd
            , Cmd.map NodeListMsg nodeListCmd
            , Cmd.map NodeDetailMsg nodeDetailCmd
            ]
        )


{-| Initialize the current route
Can update (initialize) the model for the route as well
-}
initRoute : Routing.Route -> Model -> ( Model, Cmd Msg )
initRoute route model =
    case route of
        Routing.DashboardRoute _ ->
            Dashboard.init model

        Routing.NodeListRoute query ->
            let
                ( subModel, subCmd ) =
                    NodeList.load model.config model.nodeList query
            in
                ( { model | nodeList = subModel }, Cmd.map NodeListMsg subCmd )

        Routing.NodeDetailRoute node page query ->
            let
                ( subModel, subCmd ) =
                    NodeDetail.load model.config model.nodeDetail node page
            in
                ( { model | nodeDetail = subModel }, Cmd.map NodeDetailMsg subCmd )


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
                    Routing.DashboardRoute _ ->
                        ( model
                        , Navigation.newUrl
                            (Routing.toString
                                (Routing.DashboardRoute (Just query))
                            )
                        )

                    Routing.NodeListRoute _ ->
                        ( model
                        , Navigation.newUrl
                            (Routing.toString
                                (Routing.NodeListRoute (Just query))
                            )
                        )

                    Routing.NodeDetailRoute node page _ ->
                        ( model
                        , Navigation.newUrl
                            (Routing.toString
                                (Routing.NodeDetailRoute node page (Just query))
                            )
                        )

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

            NodeListMsg msg ->
                let
                    ( subModel, subCmd ) =
                        NodeList.update msg model.nodeList
                in
                    ( { model | nodeList = subModel }, Cmd.map NodeListMsg subCmd )

            NodeDetailMsg msg ->
                let
                    ( subModel, subCmd ) =
                        NodeDetail.update msg model.nodeDetail
                in
                    ( { model | nodeDetail = subModel }, Cmd.map NodeDetailMsg subCmd )

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
