module Page.Report exposing (..)

import PuppetDB
import PuppetDB.Report exposing (Report)
import Html exposing (Html, text)
import Html.Attributes exposing (attribute, class)
import Date exposing (Date)
import Route
import Config exposing (Config)
import Json.Decode
import Task exposing (Task)
import Page.Errored as Errored exposing (PageLoadError)
import View.Page as Page
import View.EventList as EventList
import Http
import Util
import Polymer.Paper as Paper
import Polymer.Attributes exposing (boolProperty)
import FormatNumber
import FormatNumber.Locales exposing (usLocale)


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
    Paper.item [ boolProperty "disabled" True, class "static" ]
        [ Paper.itemBody [ attribute "two-line" "" ]
            [ Html.div [] [ text title ]
            , Html.div [ attribute "secondary" "" ] [ content ]
            ]
        ]


view : Model -> Route.ReportParams -> Date -> Page.Page Msg
view model routeParams date =
    { title = model.report.certname
    , onScroll = Nothing
    , content =
        Html.div [ class "content-area" ]
            [ Html.div [ class "row" ]
                [ Html.div [ class "col-xs-12 col-sm-12 col-md4 col-lg-3" ]
                    [ Paper.card []
                        [ Html.div [ class "card-content" ]
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
                                        Html.node "iron-icon" [ attribute "icon" "help" ] []
                                )
                            , item "End time" (text (Util.formattedDate model.report.endTime))
                            ]
                        ]
                    ]
                , Html.div [ class "col-xs-12 col-sm-12 col-md8 col-lg-9" ]
                    [ Paper.card []
                        [ Html.div [ class "card-content" ]
                            [ EventList.view date model.report.resourceEvents
                            ]
                        ]
                    ]
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
