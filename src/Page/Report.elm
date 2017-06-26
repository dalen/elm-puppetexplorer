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
import Http
import Polymer.Paper as Paper
import Polymer.Attributes exposing (boolProperty)


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
                        ]
                    ]
                , eventView date model.report.resourceEvents
                ]
            ]
    }


eventView : Date -> Maybe (List PuppetDB.Report.Event) -> Html Msg
eventView date events =
    Html.div [ class "col-xs-12 col-sm-12 col-md8 col-lg-9" ]
        [ Paper.card []
            [ Html.div [ class "card-content" ]
                (case events of
                    Nothing ->
                        [ text "No events found" ]

                    Just eventList ->
                        List.map (eventItem date) eventList
                )
            ]
        ]


eventItem : Date -> PuppetDB.Report.Event -> Html Msg
eventItem date event =
    text (toString event)
