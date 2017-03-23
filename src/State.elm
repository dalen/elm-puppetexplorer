module State exposing (..)

import Navigation exposing (Location)
import Debug exposing (log)
import Types exposing (..)
import UrlParser exposing (..)
import Bootstrap.Navbar


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( navbarState, navbarCmd ) =
            Bootstrap.Navbar.initialState NavbarMsg
    in
        ( { string = "Hello"
          , menubar = navbarState
          , dashboad = [ [] ]
          , route = parsePath route location
          }
        , navbarCmd
        )


route : Parser (Route -> a) a
route =
    oneOf
        [ map Dashboard (s "" <?> stringParam "query")
        , map NodeList (s "nodes" <?> stringParam "query")
        ]


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
            UpdateQuery query ->
                ( model, Navigation.newUrl ("/?query=" ++ query) )

            NewUrl url ->
                ( model, Navigation.newUrl url )

            LocationChange location ->
                { model | route = parsePath route location }
                    |> noCmd

            NoOp ->
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Bootstrap.Navbar.subscriptions model.menubar NavbarMsg
