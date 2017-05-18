module Report exposing (..)

import PuppetDB
import PuppetDB.Report exposing (Report)
import Html
import Date
import Route
import Config exposing (Config)
import Json.Decode
import Bootstrap.Card as Card
import FontAwesome.Web as Icon
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


view : Model -> Route.ReportParams -> Date.Date -> Html.Html Msg
view model routeParams date =
    Html.div []
        [ Html.h1 [] [ Html.text model.report.certname ]
        , Card.deck
            [ Card.config []
                |> Card.headerH6 [] [ Html.text "Environment" ]
                |> Card.block [] [ Card.text [] [ Html.text model.report.environment ] ]
            , Card.config []
                |> Card.headerH6 [] [ Html.text "Run time" ]
                |> Card.block [] [ Card.text [] [ Html.text "todo" ] ]
            , Card.config []
                |> Card.headerH6 [] [ Html.text "Configuration version" ]
                |> Card.block [] [ Card.text [] [ Html.text model.report.configurationVersion ] ]
            , Card.config []
                |> Card.headerH6 [] [ Html.text "Start time" ]
                |> Card.block [] [ Card.text [] [ Html.text (toString model.report.startTime) ] ]
            ]
        , Card.deck
            [ Card.config []
                |> Card.headerH6 [] [ Html.text "Puppet version" ]
                |> Card.block [] [ Card.text [] [ Html.text model.report.puppetVersion ] ]
            , Card.config []
                |> Card.headerH6 [] [ Html.text "Catalog retrieval time" ]
                |> Card.block [] [ Card.text [] [ Html.text "todo" ] ]
            , Card.config []
                |> Card.headerH6 [] [ Html.text "Catalog compiled by" ]
                |> Card.block []
                    [ Card.text []
                        [ case model.report.producer of
                            Just producer ->
                                Html.text producer

                            Nothing ->
                                Icon.question_circle
                        ]
                    ]
            , Card.config []
                |> Card.headerH6 [] [ Html.text "End time" ]
                |> Card.block [] [ Card.text [] [ Html.text (toString model.report.endTime) ] ]
            ]
        ]
