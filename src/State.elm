module State exposing (..)

import Navigation exposing (Location)
import Debug exposing (log)
import Types exposing (..)
import Bootstrap.Navbar
import Dashboard
import Routing


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( navbarState, navbarCmd ) =
            Bootstrap.Navbar.initialState NavbarMsg
    in
        ( { string = "Hello"
          , menubar = navbarState
          , route = Routing.parse location
          , dashboard =
                { panels = []
                }
          }
        , navbarCmd
        )


noCmd : Model -> ( Model, Cmd msg )
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

            -- FIXME: Take current route into account
            UpdateQueryMsg query ->
                case model.route of
                    DashboardRoute _ ->
                        ( model, Navigation.newUrl (Routing.toString (DashboardRoute (Just query))) )

                    NodeListRoute _ ->
                        ( model, Navigation.newUrl (Routing.toString (NodeListRoute (Just query))) )

            NewUrlMsg route ->
                ( model, Navigation.newUrl (Routing.toString route) )

            LocationChangeMsg location ->
                { model | route = Routing.parse location }
                    |> noCmd

            NoOpMsg ->
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Bootstrap.Navbar.subscriptions model.menubar NavbarMsg
