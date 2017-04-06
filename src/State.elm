module State exposing (..)

import Navigation exposing (Location)
import Debug exposing (log)
import Types exposing (..)
import Bootstrap.Navbar
import Routing
import Dashboard.Panel


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
                { panels =
                    [ [ Dashboard.Panel.new
                            |> Dashboard.Panel.title "Nodes"
                            |> Dashboard.Panel.bean "puppetlabs.puppetdb.population:name=num-nodes"
                      , Dashboard.Panel.new
                            |> Dashboard.Panel.title "Resources"
                            |> Dashboard.Panel.bean "puppetlabs.puppetdb.population:name=num-resources"
                      ]
                    ]
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
