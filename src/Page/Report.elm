module Page.Report exposing (..)

import PuppetDB
import PuppetDB.Report exposing (Report)
import Html exposing (Html, text)
import Html.Attributes exposing (attribute)
import Date
import Route
import Config exposing (Config)
import Json.Decode
import Task exposing (Task)
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import Http
import Polymer.Paper as Paper


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


item : String -> Html.Html msg -> Html.Html msg
item title content =
    Paper.item []
        [ Paper.itemBody [ attribute "two-line" "" ]
            [ Html.div [] [ text title ]
            , Html.div [ attribute "secondary" "" ] [ content ]
            ]
        ]


view : Model -> Route.ReportParams -> Date.Date -> Page.Page Msg
view model routeParams date =
    { title = model.report.certname
    , content =
        Paper.card []
            [ item "Environment" (text model.report.environment)
            , item "Run time" (text "todo")
            , item "Configuration version" (text model.report.configurationVersion)
            , item "Start time" (text (toString model.report.startTime))
            , item "Puppet version" (text model.report.puppetVersion)
            , item "Catalog retrieval time" (text "todo")
            , item "Catalog compiled by"
                (case model.report.producer of
                    Just producer ->
                        text producer

                    Nothing ->
                        Html.node "iron-icon" [ attribute "icon" "help" ] []
                )
            , item "End time" (text (toString model.report.endTime))
            ]
    }
