module Main exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar
import Bootstrap.Form.InputGroup as InputGroup
import Bootstrap.Form.Input as Input
import FontAwesome.Web as Icon
import Routing exposing (Route)
import Config exposing (Config, DashboardPanelConfig)
import Dashboard
import NodeDetail
import NodeList
import Report
import Html
import Html.Events
import Events
import Date
import Date.Extra
import Time
import View.Page as Page


type Page
    = Blank
    | NotFound
    | Dashboard Routing.DashboardRouteParams Dashboard.Model
    | NodeList Routing.NodeListRouteParams NodeList.Model
    | NodeDetail Routing.NodeDetailRouteParams NodeDetail.Model
    | Report Routing.ReportRouteParams Report.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- Model


type alias Model =
    { config : Config
    , navbarState : Bootstrap.Navbar.State
    , queryField : String
    , date : Date.Date
    , pageState : Page
    }


init : Config -> Location -> ( Model, Cmd Msg )
init config location =
    let
        ( navbarState, navbarCmd ) =
            Bootstrap.Navbar.initialState NavbarMsg

        ( model, routeCmd ) =
            setRoute (Routing.parse location)
                { config = config
                , navbarState = navbarState
                , queryField = ""
                , date = Date.Extra.fromCalendarDate 2017 Date.Jan 1
                , pageState = Blank
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
setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg page ( pageModel, pageCmd ) =
            ( { model | pageState = page pageModel }, Cmd.map toMsg pageCmd )
    in
        case maybeRoute of
            Nothing ->
                transition DashboardMsg (Dashboard { query = Nothing }) (Dashboard.load model.config Dashboard.initModel { query = Nothing })

            Just (Routing.DashboardRoute params) ->
                transition DashboardMsg (Dashboard params) (Dashboard.load model.config Dashboard.initModel params)

            Just (Routing.NodeListRoute params) ->
                transition NodeListMsg (NodeList params) (NodeList.load model.config NodeList.initModel params)

            Just (Routing.NodeDetailRoute params) ->
                transition NodeDetailMsg (NodeDetail params) (NodeDetail.load model.config NodeDetail.initModel params)

            Just (Routing.ReportRoute params) ->
                transition ReportMsg (Report params) (Report.load model.config Report.initModel params)



-- Update


type Msg
    = NavbarMsg Bootstrap.Navbar.State
    | TimeMsg Time.Time
    | UpdateQueryMsg String
    | SubmitQueryMsg String
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | DashboardMsg Dashboard.Msg
    | NodeListMsg NodeList.Msg
    | NodeDetailMsg NodeDetail.Msg
    | ReportMsg Report.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage model.pageState msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        _ =
            case msg of
                TimeMsg _ ->
                    msg

                _ ->
                    Debug.log "update" msg

        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
                ( { model | pageState = toModel newModel }, Cmd.map toMsg newCmd )
    in
        case ( msg, page ) of
            ( NavbarMsg state, _ ) ->
                ( { model | navbarState = state }, Cmd.none )

            ( UpdateQueryMsg query, _ ) ->
                ( { model | queryField = query }, Cmd.none )

            ( SubmitQueryMsg query, _ ) ->
                ( model, Cmd.none )

            -- Can this be simplified?
            {- case model.route of
               Routing.DashboardRoute params ->
                   ( model
                   , Navigation.newUrl
                       (Routing.toString
                           (Routing.DashboardRoute { params | query = Just model.queryField })
                       )
                   )

               Routing.NodeListRoute params ->
                   ( model
                   , Navigation.newUrl
                       (Routing.toString
                           (Routing.NodeListRoute { params | query = Just model.queryField })
                       )
                   )

               Routing.NodeDetailRoute params ->
                   ( model
                   , Routing.newUrl
                       (Routing.NodeDetailRoute { params | query = Just model.queryField })
                   )

               Routing.ReportRoute params ->
                   ( model
                   , Routing.newUrl
                       (Routing.ReportRoute { params | query = Just model.queryField })
                   )
            -}
            ( NewUrlMsg route, _ ) ->
                ( model, Routing.newUrl route )

            ( LocationChangeMsg location, _ ) ->
                setRoute (Routing.parse location) model

            ( DashboardMsg subMsg, Dashboard params subModel ) ->
                toPage (Dashboard params) DashboardMsg Dashboard.update subMsg subModel

            ( NodeListMsg subMsg, NodeList params subModel ) ->
                toPage (NodeList params) NodeListMsg NodeList.update subMsg subModel

            ( NodeDetailMsg subMsg, NodeDetail params subModel ) ->
                toPage (NodeDetail params) NodeDetailMsg NodeDetail.update subMsg subModel

            ( ReportMsg subMsg, Report params subModel ) ->
                toPage (Report params) ReportMsg Report.update subMsg subModel

            ( TimeMsg time, _ ) ->
                ( { model | date = Date.fromTime time }, Cmd.none )

            ( _, NotFound ) ->
                -- Disregard incoming messages when we're on the
                -- NotFound page.
                ( model, Cmd.none )

            ( _, _ ) ->
                -- Disregard incoming messages that arrived for the wrong page
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Bootstrap.Navbar.subscriptions model.navbarState NavbarMsg
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


searchField : String -> Html.Html Msg
searchField query =
    InputGroup.config
        (InputGroup.search
            [ Input.attrs [ Html.Events.onInput UpdateQueryMsg, Events.onChange SubmitQueryMsg ]
            ]
        )
        |> InputGroup.predecessors
            [ InputGroup.span [] [ Icon.search ]
            , InputGroup.span [] [ Html.text "inventory {" ]
            ]
        |> InputGroup.successors
            [ InputGroup.span [] [ Html.text "}" ]
            ]
        |> InputGroup.view


viewPage : Model -> Page -> Html.Html Msg
viewPage model page =
    let
        frame =
            Page.frame (Just model.queryField) UpdateQueryMsg SubmitQueryMsg NewUrlMsg model.navbarState NavbarMsg
    in
        case page of
            Blank ->
                Dashboard.view model.config Dashboard.initModel
                    |> Html.map DashboardMsg
                    |> frame Page.Dashboard

            NotFound ->
                Dashboard.view model.config Dashboard.initModel
                    |> Html.map DashboardMsg
                    |> frame Page.Dashboard

            Dashboard params subModel ->
                Dashboard.view model.config subModel
                    |> Html.map DashboardMsg
                    |> frame Page.Dashboard

            NodeList params subModel ->
                NodeList.view subModel params model.date
                    |> Html.map NodeListMsg
                    |> frame Page.Nodes

            NodeDetail params subModel ->
                NodeDetail.view subModel params model.date
                    |> Html.map NodeDetailMsg
                    |> frame Page.Nodes

            Report params subModel ->
                Report.view subModel params model.date
                    |> Html.map ReportMsg
                    |> frame Page.Nodes


view : Model -> Html.Html Msg
view model =
    viewPage model model.pageState


main : Program Config.Config Model Msg
main =
    Navigation.programWithFlags LocationChangeMsg
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
