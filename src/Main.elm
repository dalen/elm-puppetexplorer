module Main exposing (..)

import Navigation exposing (Location)
import Route exposing (Route)
import Config exposing (Config, DashboardPanelConfig)
import Page.Dashboard as Dashboard
import Page.NodeDetail as NodeDetail
import Page.NodeList as NodeList
import Page.Report as Report
import Page.Errored as Errored exposing (PageLoadError)
import Page.Loading as Loading
import Html exposing (Html)
import Date
import Date.Extra
import Time
import View.Page as Page
import View.Toolbar as Toolbar
import Task
import Ports
import Material
import Bootstrap.Navbar as Navbar


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Dashboard Dashboard.Model
    | NodeList Route.NodeListParams NodeList.Model
    | NodeDetail Route.NodeDetailParams NodeDetail.Model
    | Report Route.ReportParams Report.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- Model


type alias Model =
    { mdl : Material.Model
    , navbar : Navbar.State
    , config : Config
    , date : Date.Date
    , pageState : PageState
    }


init : Config -> Location -> ( Model, Cmd Msg )
init config location =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        ( model, routeCmd ) =
            setRoute (Route.parse location)
                { mdl = Material.model
                , navbar = navbarState
                , config = config
                , date = Date.Extra.fromCalendarDate 2017 Date.Jan 1
                , pageState = Loaded Blank
                }
    in
        ( model
        , Cmd.batch [ routeCmd, navbarCmd, Material.init Mdl ]
        )


{-| Initialize the current route
Can update (initialize) the model for the route as well
-}
setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            ( { model | pageState = TransitioningFrom (getPage model.pageState) }
            , Task.attempt toMsg task
            )
    in
        case maybeRoute of
            Nothing ->
                ( { model | pageState = Loaded NotFound }, Cmd.none )

            Just Route.Dashboard ->
                transition DashboardLoaded (Dashboard.init model.config)

            Just (Route.NodeList params) ->
                transition (NodeListLoaded params) (NodeList.init model.config params)

            Just (Route.NodeDetail params) ->
                transition (NodeDetailLoaded params) (NodeDetail.init model.config params)

            Just (Route.Report params) ->
                transition (ReportLoaded params) (Report.init model.config params)



-- Update


type Msg
    = Mdl (Material.Msg Msg)
    | NavbarMsg Navbar.State
    | TimeMsg Time.Time
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | DashboardLoaded (Result PageLoadError Dashboard.Model)
    | NodeListLoaded Route.NodeListParams (Result PageLoadError NodeList.Model)
    | NodeDetailLoaded Route.NodeDetailParams (Result PageLoadError NodeDetail.Model)
    | ReportLoaded Route.ReportParams (Result PageLoadError Report.Model)
    | DashboardMsg Never
    | NodeListMsg NodeList.Msg
    | NodeDetailMsg NodeDetail.Msg
    | ReportMsg Report.Msg
    | ScrollMsg Int
    | Noop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


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
                case model.pageState of
                    Loaded page ->
                        ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )

                    TransitioningFrom page ->
                        ( { model | pageState = TransitioningFrom (toModel newModel) }, Cmd.map toMsg newCmd )
    in
        case ( msg, page ) of
            ( Mdl mdlMsg, _ ) ->
                Material.update Mdl mdlMsg model

            ( NavbarMsg state, _ ) ->
                ( { model | navbar = state }, Cmd.none )

            ( DashboardLoaded (Ok subModel), _ ) ->
                -- TODO: handle the params
                ( { model | pageState = Loaded (Dashboard subModel) }, Cmd.none )

            ( DashboardLoaded (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }, Cmd.none )

            ( NodeListLoaded params (Ok subModel), _ ) ->
                ( { model | pageState = Loaded (NodeList params subModel) }, Cmd.none )

            ( NodeListLoaded _ (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }, Cmd.none )

            ( NodeDetailLoaded params (Ok subModel), _ ) ->
                ( { model | pageState = Loaded (NodeDetail params subModel) }, Cmd.none )

            ( NodeDetailLoaded _ (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }, Cmd.none )

            ( ReportLoaded params (Ok subModel), _ ) ->
                ( { model | pageState = Loaded (Report params subModel) }, Cmd.none )

            ( ReportLoaded _ (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }, Cmd.none )

            ( NewUrlMsg route, _ ) ->
                ( model, Route.newUrl route )

            ( LocationChangeMsg location, _ ) ->
                setRoute (Route.parse location) model

            ( NodeListMsg subMsg, NodeList params subModel ) ->
                toPage (NodeList params) NodeListMsg NodeList.update subMsg subModel

            ( ScrollMsg _, NodeList params subModel ) ->
                toPage (NodeList params) NodeListMsg NodeList.update NodeList.grow subModel

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
        [ Time.every Time.second TimeMsg
        , Ports.scrollBottom ScrollMsg
        , Material.subscriptions Mdl model
        , Navbar.subscriptions model.navbar NavbarMsg
        ]


andThen : (Model -> ( Model, Cmd msg )) -> ( Model, Cmd msg ) -> ( Model, Cmd msg )
andThen advance ( beginModel, cmd1 ) =
    let
        ( newModel, cmd2 ) =
            advance beginModel
    in
        ( newModel, Cmd.batch [ cmd1, cmd2 ] )



-- View


viewPage : Model -> Bool -> Page -> Html Msg
viewPage model loading page =
    let
        frame =
            Page.frame NavbarMsg model.navbar
    in
        case page of
            Blank ->
                Loading.view
                    |> Page.Page loading (Toolbar.Title "Loading")
                    |> frame Page.Dashboard

            NotFound ->
                Html.div [] [ Html.text "Page not found" ]
                    |> Page.Page loading (Toolbar.Title "Page not found")
                    |> frame Page.Other

            Errored subModel ->
                Errored.view subModel
                    |> Page.Page loading (Toolbar.Title "Error")
                    |> frame Page.Other

            Dashboard subModel ->
                Dashboard.view subModel
                    |> Html.map DashboardMsg
                    |> Page.Page loading (Toolbar.Title "Dashboard")
                    |> frame Page.Dashboard

            NodeList params subModel ->
                NodeList.view model.mdl Mdl subModel params model.date NodeListMsg
                    |> Page.addLoading loading
                    |> frame Page.Nodes

            NodeDetail params subModel ->
                NodeDetail.view subModel params model.date NodeDetailMsg
                    |> Page.addLoading loading
                    |> frame Page.Nodes

            Report params subModel ->
                Report.view subModel params model.date ReportMsg
                    |> Page.addLoading loading
                    |> frame Page.Nodes


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage model False page

        TransitioningFrom page ->
            viewPage model True page


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page


main : Program Config.Config Model Msg
main =
    Navigation.programWithFlags LocationChangeMsg
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
