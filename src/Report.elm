module Report exposing (..)

import PuppetDB
import PuppetDB.Report
import Html
import Date
import Route
import RemoteData exposing (WebData)
import Config exposing (Config)
import Json.Decode
import Error
import Bootstrap.Progress as Progress
import Bootstrap.Card as Card
import FontAwesome.Web as Icon


type alias Model =
    { routeParams : Route.ReportParams
    , report : WebData PuppetDB.Report.Report
    }


type Msg
    = ChangePage Int
    | UpdateReport (WebData PuppetDB.Report.Report)


initModel : Model
initModel =
    { routeParams = Route.ReportParams "" Nothing Nothing
    , report = RemoteData.NotAsked
    }



-- FIXME: Don't reload if already loaded the report


load : Config -> Model -> Route.ReportParams -> ( Model, Cmd Msg )
load config model routeParams =
    ( { model
        | report = RemoteData.Loading
      }
    , PuppetDB.queryPQL
        config.serverUrl
        (PuppetDB.pql "reports"
            []
            ("hash=\""
                ++ routeParams.hash
                ++ "\""
            )
        )
        (Json.Decode.index 0 PuppetDB.Report.decoder)
        UpdateReport
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateReport response ->
            ( { model | report = response }, Cmd.none )

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
    case model.report of
        RemoteData.Success report ->
            Html.div []
                [ Html.h1 [] [ Html.text report.certname ]
                , Card.deck
                    [ Card.config []
                        |> Card.headerH6 [] [ Html.text "Environment" ]
                        |> Card.block [] [ Card.text [] [ Html.text report.environment ] ]
                    , Card.config []
                        |> Card.headerH6 [] [ Html.text "Run time" ]
                        |> Card.block [] [ Card.text [] [ Html.text "todo" ] ]
                    , Card.config []
                        |> Card.headerH6 [] [ Html.text "Configuration version" ]
                        |> Card.block [] [ Card.text [] [ Html.text report.configurationVersion ] ]
                    , Card.config []
                        |> Card.headerH6 [] [ Html.text "Start time" ]
                        |> Card.block [] [ Card.text [] [ Html.text (toString report.startTime) ] ]
                    ]
                , Card.deck
                    [ Card.config []
                        |> Card.headerH6 [] [ Html.text "Puppet version" ]
                        |> Card.block [] [ Card.text [] [ Html.text report.puppetVersion ] ]
                    , Card.config []
                        |> Card.headerH6 [] [ Html.text "Catalog retrieval time" ]
                        |> Card.block [] [ Card.text [] [ Html.text "todo" ] ]
                    , Card.config []
                        |> Card.headerH6 [] [ Html.text "Catalog compiled by" ]
                        |> Card.block []
                            [ Card.text []
                                [ case report.producer of
                                    Just producer ->
                                        Html.text producer

                                    Nothing ->
                                        Icon.question_circle
                                ]
                            ]
                    , Card.config []
                        |> Card.headerH6 [] [ Html.text "End time" ]
                        |> Card.block [] [ Card.text [] [ Html.text (toString report.endTime) ] ]
                    ]
                ]

        RemoteData.Failure error ->
            Error.alert "loading report" error

        _ ->
            Progress.progress
                [ Progress.label "Loading reports..."
                , Progress.animated
                , Progress.value 100
                ]
