module Page.Report exposing (..)

import PuppetDB
import PuppetDB.Report exposing (Report)
import Html exposing (Html, text)
import Html.Attributes exposing (attribute, class)
import Date exposing (Date)
import Route
import Route.Report exposing (Tab(..))
import Config exposing (Config)
import Json.Decode
import Task exposing (Task)
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import View.Toolbar as Toolbar
import View.EventList as EventList
import Http
import Util
import Material.Grid as Grid
import Material.Card as Card
import Material.Elevation as Elevation
import Material.List as Lists
import Material.Icon as Icon
import FormatNumber
import FormatNumber.Locales exposing (usLocale)


type alias Model =
    { routeParams : Route.ReportParams
    , report : PuppetDB.Report.Report
    }


type Msg
    = ChangePage Int
    | SelectTab Int


init : Config.Config -> Route.ReportParams -> Task PageLoadError Model
init config params =
    Task.map (Model params)
        (getReport config.serverUrl params.hash)


getReport : String -> String -> Task PageLoadError Report
getReport serverUrl hash =
    PuppetDB.request
        serverUrl
        (PuppetDB.pql "reports"
            []
            ("hash=\""
                ++ hash
                ++ "\""
            )
        )
        (Json.Decode.index 0 PuppetDB.Report.decoder)
        |> Http.toTask
        |> Task.mapError (Errored.httpError Page.Nodes "loading report")


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTab tab ->
            let
                routeParams =
                    model.routeParams
            in
                ( model, Route.newUrl (Route.Report { routeParams | tab = Route.Report.fromIndex tab }) )

        ChangePage page ->
            let
                routeParams =
                    model.routeParams
            in
                ( model
                , Route.newUrl (Route.Report routeParams)
                )


item : String -> Html msg -> Html msg
item title content =
    Lists.li [ Lists.withSubtitle ]
        [ Lists.content []
            [ text title
            , Lists.subtitle [] [ content ]
            ]
        ]


view : Model -> Route.ReportParams -> Date -> (Msg -> msg) -> Page.Page msg
view model routeParams date msg =
    { loading = False
    , toolbar = Toolbar.Title ("Report for " ++ model.report.certname)
    , tabs = ( [ text "Events", text "Logs", text "Metrics" ], [] )
    , selectedTab = Route.Report.toIndex routeParams.tab
    , onSelectTab = Just (SelectTab >> msg)
    , content =
        Grid.grid []
            [ Grid.cell [ Grid.size Grid.Phone 4, Grid.size Grid.Tablet 8, Grid.size Grid.Desktop 4 ]
                [ Card.view [ Elevation.e2 ]
                    [ Card.text []
                        [ Lists.ul []
                            [ item "Environment" (text model.report.environment)
                            , item "Run time" (showMetric 1 (Just "s") "time" "total" model.report)
                            , item "Configuration version" (text model.report.configurationVersion)
                            , item "Start time" (text (Util.formattedDate model.report.startTime))
                            , item "Puppet version" (text model.report.puppetVersion)
                            , item "Catalog retrieval time" (showMetric 1 (Just "s") "time" "total" model.report)
                            , item "Catalog compiled by"
                                (case model.report.producer of
                                    Just producer ->
                                        text producer

                                    Nothing ->
                                        Icon.view "help" []
                                )
                            , item "End time" (text (Util.formattedDate model.report.endTime))
                            ]
                        ]
                    ]
                ]
            , Grid.cell [ Grid.size Grid.All 8 ]
                [ EventList.view date model.report.resourceEvents
                ]
            ]
    }


showMetric : Int -> Maybe String -> String -> String -> Report -> Html msg
showMetric decimals unit name category report =
    case (PuppetDB.Report.getMetric "time" "total" report) of
        Just metric ->
            text
                ((FormatNumber.format { usLocale | decimals = decimals } metric)
                    ++ (Maybe.withDefault "" unit)
                )

        Nothing ->
            Html.node "iron-icon" [ attribute "icon" "help" ] []
