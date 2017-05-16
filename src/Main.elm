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
import Page.Errored as Errored exposing (PageLoadError)
import Html
import Html.Events
import Html.Attributes as Attributes
import Events
import Date
import Date.Extra
import Time
import View.Page as Page
import Task


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
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
    , pageState : PageState
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
                , pageState = Loaded Blank
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
        transitionOld toMsg page ( pageModel, pageCmd ) =
            ( { model | pageState = TransitioningFrom (page pageModel) }, Cmd.map toMsg pageCmd )

        transition toMsg task =
            ( { model | pageState = TransitioningFrom (getPage model.pageState) }
            , Task.attempt toMsg task
            )
    in
        case maybeRoute of
            Nothing ->
                ( { model | pageState = Loaded NotFound }, Cmd.none )

            Just (Routing.DashboardRoute params) ->
                transition DashboardLoaded (Dashboard.init model.config params)

            --transitionOld DashboardMsg (Dashboard params) (Dashboard.load model.config Dashboard.initModel params)
            Just (Routing.NodeListRoute params) ->
                transitionOld NodeListMsg (NodeList params) (NodeList.load model.config NodeList.initModel params)

            Just (Routing.NodeDetailRoute params) ->
                transitionOld NodeDetailMsg (NodeDetail params) (NodeDetail.load model.config NodeDetail.initModel params)

            Just (Routing.ReportRoute params) ->
                transitionOld ReportMsg (Report params) (Report.load model.config Report.initModel params)



-- Update


type Msg
    = NavbarMsg Bootstrap.Navbar.State
    | TimeMsg Time.Time
    | UpdateQueryMsg String
    | SubmitQueryMsg String
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | DashboardLoaded (Result PageLoadError Dashboard.Model)
    | DashboardMsg Dashboard.Msg
    | NodeListMsg NodeList.Msg
    | NodeDetailMsg NodeDetail.Msg
    | ReportMsg Report.Msg


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
                ( { model | pageState = TransitioningFrom (toModel newModel) }, Cmd.map toMsg newCmd )
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
            ( DashboardLoaded (Ok subModel), _ ) ->
                -- TODO: handle the params
                ( { model | pageState = Loaded (Dashboard { query = Nothing } subModel) }, Cmd.none )

            ( DashboardLoaded (Err error), _ ) ->
                ( { model | pageState = Loaded (Errored error) }, Cmd.none )

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


viewPage : Model -> Bool -> Page -> Html.Html Msg
viewPage model loading page =
    let
        frame =
            Page.frame loading (Just model.queryField) UpdateQueryMsg SubmitQueryMsg NewUrlMsg model.navbarState NavbarMsg
    in
        case page of
            Blank ->
                Html.i [ Attributes.class "fa fa-spinner fa-spin", Attributes.style [ ( "size", "50" ) ] ] []
                    |> frame Page.Dashboard

            NotFound ->
                Dashboard.view model.config Dashboard.initModel
                    |> Html.map DashboardMsg
                    |> frame Page.Dashboard

            Errored subModel ->
                Errored.view subModel
                    |> frame Page.Other

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
