module Main exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar
import Bootstrap.Form.Input as Input
import Bootstrap.Alert as Alert
import Bootstrap.Grid as Grid
import FontAwesome.Web as Icon
import Routing exposing (Route)
import Menubar
import Config exposing (Config, DashboardPanelConfig)
import Dashboard
import NodeDetail
import NodeList
import Html
import Html.Attributes as Attributes
import Events
import Date
import Date.Extra
import Time


type alias Model =
    { config : Config
    , messages : List String
    , menubar : Bootstrap.Navbar.State
    , route : Route
    , dashboard : Dashboard.Model
    , nodeList : NodeList.Model
    , nodeDetail : NodeDetail.Model
    , date : Date.Date
    }


type Msg
    = NavbarMsg Bootstrap.Navbar.State
    | TimeMsg Time.Time
    | UpdateQueryMsg String
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | DashboardMsg Dashboard.Msg
    | NodeListMsg NodeList.Msg
    | NodeDetailMsg NodeDetail.Msg
    | NoopMsg



-- Init & Update


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
        Routing.DashboardRoute params ->
            let
                ( subModel, subCmd ) =
                    Dashboard.load model.config model.dashboard params
            in
                ( { model | dashboard = subModel }, Cmd.map DashboardMsg subCmd )

        Routing.NodeListRoute params ->
            let
                ( subModel, subCmd ) =
                    NodeList.load model.config model.nodeList params
            in
                ( { model | nodeList = subModel }, Cmd.map NodeListMsg subCmd )

        Routing.NodeDetailRoute params ->
            let
                ( subModel, subCmd ) =
                    NodeDetail.load model.config model.nodeDetail params
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
                -- Can this be simplified?
                case model.route of
                    Routing.DashboardRoute params ->
                        ( model
                        , Navigation.newUrl
                            (Routing.toString
                                (Routing.DashboardRoute { params | query = Just query })
                            )
                        )

                    Routing.NodeListRoute params ->
                        ( model
                        , Navigation.newUrl
                            (Routing.toString
                                (Routing.NodeListRoute { params | query = Just query })
                            )
                        )

                    Routing.NodeDetailRoute params ->
                        ( model
                        , Navigation.newUrl
                            (Routing.toString
                                (Routing.NodeDetailRoute { params | query = Just query })
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



-- View


header : Maybe String -> Model -> Html.Html Msg -> Html.Html Msg
header query model page =
    Html.div []
        [ searchField query
        , Menubar.view query model.route NewUrlMsg model.menubar NavbarMsg
        , Grid.containerFluid []
            (List.map (\message -> Alert.warning [ Html.text message ]) model.messages)
        , Grid.containerFluid [] [ page ]
        ]


searchField : Maybe String -> Html.Html Msg
searchField query =
    Html.div [ Attributes.class "input-group" ]
        [ Html.span [ Attributes.class "input-group-addon" ] [ Icon.search ]
        , Input.search
            [ Input.value (Maybe.withDefault "" query)
            , Input.attrs [ Events.onChange UpdateQueryMsg ]
            ]
        ]


view : Model -> Html.Html Msg
view model =
    case model.route of
        Routing.DashboardRoute params ->
            header params.query
                model
                (Html.map DashboardMsg (Dashboard.view model.config model.dashboard))

        Routing.NodeListRoute params ->
            header params.query
                model
                (Html.map NodeListMsg (NodeList.view model.nodeList params model.date))

        Routing.NodeDetailRoute params ->
            header params.query
                model
                (Html.map NodeDetailMsg (NodeDetail.view model.nodeDetail params model.date))


main : Program Config.Config Model Msg
main =
    Navigation.programWithFlags LocationChangeMsg
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
