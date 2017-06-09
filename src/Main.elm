module Main exposing (..)

import Material
import Navigation exposing (Location)
import Material.Layout as Layout
import Route exposing (Route)
import Config exposing (Config, DashboardPanelConfig)
import Page.Dashboard as Dashboard
import Page.NodeDetail as NodeDetail
import Page.NodeList as NodeList
import Page.Report as Report
import Page.Errored as Errored exposing (PageLoadError)
import Html
import Html.Attributes as Attributes
import Date
import Date.Extra
import Time
import View.Page as Page
import Task


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Dashboard Route.DashboardParams Dashboard.Model
    | NodeList Route.NodeListParams NodeList.Model
    | NodeDetail Route.NodeDetailParams NodeDetail.Model
    | Report Route.ReportParams Report.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- Model


type alias Model =
    { config : Config
    , mdl : Material.Model
    , queryField : String
    , date : Date.Date
    , pageState : PageState
    }


init : Config -> Location -> ( Model, Cmd Msg )
init config location =
    let
        ( model, routeCmd ) =
            setRoute (Route.parse location)
                { config = config
                , mdl = Material.model
                , queryField = ""
                , date = Date.Extra.fromCalendarDate 2017 Date.Jan 1
                , pageState = Loaded Blank
                }
    in
        ( model
        , Cmd.batch
            [ routeCmd
            , Layout.sub0 Mdl
            ]
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

            Just (Route.Dashboard params) ->
                transition DashboardLoaded (Dashboard.init model.config params)

            Just (Route.NodeList params) ->
                transition (NodeListLoaded params) (NodeList.init model.config params)

            Just (Route.NodeDetail params) ->
                transition (NodeDetailLoaded params) (NodeDetail.init model.config params)

            Just (Route.Report params) ->
                transition (ReportLoaded params) (Report.init model.config params)



-- Update


type Msg
    = Mdl (Material.Msg Msg)
    | TimeMsg Time.Time
    | UpdateQueryMsg String
    | SubmitQueryMsg String
    | SelectTab Int
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | DashboardLoaded (Result PageLoadError Dashboard.Model)
    | NodeListLoaded Route.NodeListParams (Result PageLoadError NodeList.Model)
    | NodeDetailLoaded Route.NodeDetailParams (Result PageLoadError NodeDetail.Model)
    | ReportLoaded Route.ReportParams (Result PageLoadError Report.Model)
    | DashboardMsg Never
    | NodeListMsg Never
    | NodeDetailMsg NodeDetail.Msg
    | ReportMsg Report.Msg
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
                ( { model | pageState = TransitioningFrom (toModel newModel) }, Cmd.map toMsg newCmd )
    in
        case ( msg, page ) of
            ( Mdl subMsg, _ ) ->
                Material.update Mdl subMsg model

            ( SelectTab num, _ ) ->
                ( model
                , Route.newUrl
                    (case num of
                        0 ->
                            Route.Dashboard { query = Nothing }

                        1 ->
                            Route.NodeList { query = Nothing }

                        _ ->
                            Route.Dashboard { query = Nothing }
                    )
                )

            ( UpdateQueryMsg query, _ ) ->
                ( { model | queryField = query }, Cmd.none )

            ( SubmitQueryMsg query, _ ) ->
                ( model, Cmd.none )

            -- Can this be simplified?
            {- case model.route of
               Route.Dashboard params ->
                   ( model
                   , Navigation.newUrl
                       (Route.toString
                           (Route.Dashboard { params | query = Just model.queryField })
                       )
                   )

               Route.NodeList params ->
                   ( model
                   , Navigation.newUrl
                       (Route.toString
                           (Route.NodeList { params | query = Just model.queryField })
                       )
                   )

               Route.NodeDetail params ->
                   ( model
                   , Route.newUrl
                       (Route.NodeDetail { params | query = Just model.queryField })
                   )

               Route.Report params ->
                   ( model
                   , Route.newUrl
                       (Route.Report { params | query = Just model.queryField })
                   )
            -}
            ( DashboardLoaded (Ok subModel), _ ) ->
                -- TODO: handle the params
                ( { model | pageState = Loaded (Dashboard { query = Nothing } subModel) }, Cmd.none )

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
        , Layout.subs Mdl model.mdl
        ]


andThen : (Model -> ( Model, Cmd msg )) -> ( Model, Cmd msg ) -> ( Model, Cmd msg )
andThen advance ( beginModel, cmd1 ) =
    let
        ( newModel, cmd2 ) =
            advance beginModel
    in
        ( newModel, Cmd.batch [ cmd1, cmd2 ] )



-- View


viewPage : Model -> Bool -> Page -> Html.Html Msg
viewPage model loading page =
    let
        frame =
            Page.frame loading (Just model.queryField) Mdl model.mdl
    in
        case page of
            Blank ->
                Html.i [ Attributes.class "fa fa-spinner fa-spin", Attributes.style [ ( "size", "50" ) ] ] []
                    |> Page.Page "Loading"
                    |> frame Page.Dashboard

            NotFound ->
                Html.div [] [ Html.text "Page not found" ]
                    |> Page.Page "Page not found"
                    |> frame Page.Other

            Errored subModel ->
                Errored.view subModel
                    |> Page.Page "Error"
                    |> frame Page.Other

            Dashboard params subModel ->
                Dashboard.view subModel
                    |> Html.map DashboardMsg
                    |> Page.Page "Dashboard"
                    |> frame Page.Dashboard

            NodeList params subModel ->
                NodeList.view subModel params model.date
                    |> Html.map NodeListMsg
                    |> Page.Page "Nodes"
                    |> frame Page.Nodes

            NodeDetail params subModel ->
                NodeDetail.view subModel params model.date
                    |> Page.map (Html.map NodeDetailMsg)
                    |> frame Page.Nodes

            Report params subModel ->
                Report.view subModel params model.date
                    |> Page.map (Html.map ReportMsg)
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
