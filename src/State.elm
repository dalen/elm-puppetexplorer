module State exposing (..)

import Navigation exposing (Location)
import Debug exposing (log)
import Types exposing (..)
import Bootstrap.Navbar
import Routing
import Dashboard
import NodeList
import NodeDetail
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

        ( model, routeCmd ) =
            initRoute
                { config = config
                , messages = []
                , menubar = navbarState
                , route = route
                , dashboard = Dashboard.initModel
                , nodeList = NodeList.initModel
                , nodeDetail = NodeDetail.initModel
                , date = Date.Extra.fromCalendarDate 2017 Date.Jan 1
                }
    in
        ( model
        , Cmd.batch
            [ routeCmd
            , navbarCmd
            ]
        )


{-| Initialize the current route
Can update (initialize) the model for the route as well
-}
initRoute : Model -> ( Model, Cmd Msg )
initRoute model =
    case model.route of
        Routing.DashboardRoute _ ->
            let
                ( subModel, subCmd ) =
                    Dashboard.load model.config model.dashboard
            in
                ( { model | dashboard = subModel }, Cmd.map DashboardMsg subCmd )

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
                initRoute { model | route = Routing.parse location }

            DashboardMsg msg ->
                let
                    ( subModel, subCmd ) =
                        Dashboard.update msg model.dashboard
                in
                    ( { model | dashboard = subModel }, Cmd.map DashboardMsg subCmd )

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
