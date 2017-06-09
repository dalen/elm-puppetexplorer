module Page.Report exposing (..)

import PuppetDB
import PuppetDB.Report exposing (Report)
import Html
import Date
import Route
import Config exposing (Config)
import Json.Decode
import Material.Card as Card
import Material.Icon as Icon
import Material.Grid as Grid
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Options as Options
import Material.Typography as Typography
import Task exposing (Task)
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import Http


type alias Model =
    { routeParams : Route.ReportParams
    , report : PuppetDB.Report.Report
    }


type Msg
    = ChangePage Int


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
        ChangePage page ->
            let
                routeParams =
                    model.routeParams
            in
                ( model
                , Route.newUrl (Route.Report { routeParams | page = Just page })
                )


card : String -> Html.Html msg -> Grid.Cell msg
card title content =
    Grid.cell [ Grid.size Grid.All 3 ]
        [ Card.view [ Elevation.e2, Options.css "width" "100%" ]
            [ Card.title [] [ Card.head [] [ Html.text title ] ]
            , Card.text [ Card.expand, Color.text Color.accent, Typography.center ]
                [ Options.span [ Typography.display3 ] [ content ] ]
            ]
        ]


view : Model -> Route.ReportParams -> Date.Date -> Page.Page Msg
view model routeParams date =
    { title = model.report.certname
    , content =
        Grid.grid []
            [ card "Environment" (Html.text model.report.environment)
            , card "Run time" (Html.text "todo")
            , card "Configuration version" (Html.text model.report.configurationVersion)
            , card "Start time" (Html.text (toString model.report.startTime))
            , card "Puppet version" (Html.text model.report.puppetVersion)
            , card "Catalog retrieval time" (Html.text "todo")
            , card "Catalog compiled by"
                (case model.report.producer of
                    Just producer ->
                        Html.text producer

                    Nothing ->
                        Icon.i "help"
                )
            , card "End time" (Html.text (toString model.report.endTime))
            ]
    }
