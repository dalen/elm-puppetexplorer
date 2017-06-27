module View.EventList exposing (view)

import Html exposing (Html, text)
import Html.Keyed
import Html.Attributes as Attr exposing (attribute, class)
import Date exposing (Date)
import PuppetDB.Report as Report
import Polymer.Paper as Paper


view : Date -> Maybe (List Report.Event) -> Html msg
view date eventList =
    case eventList of
        Just events ->
            Html.Keyed.node "div"
                [ Attr.id "report" ]
                (List.map (itemView date) events)

        Nothing ->
            Html.div [] [ text "No events found" ]


itemView : Date -> Report.Event -> ( String, Html msg )
itemView date event =
    ( "node-report-" ++ "report.hash"
    , Paper.item [ attribute "disabled" "", Attr.class "static" ]
        [ Paper.itemBody [ attribute "two-line" "" ]
            [ Html.div [] [ text (event.resourceType ++ "[" ++ event.resourceTitle ++ "]") ]
            , Html.div [ attribute "secondary" "" ] [ text (Maybe.withDefault "" event.message) ]
            ]
        , statusIcon event.status
        ]
    )


statusIcon : Report.EventStatus -> Html msg
statusIcon status =
    case status of
        Report.Success ->
            Html.node "iron-icon" [ attribute "icon" "check-circle", Attr.class "eventstatus-success" ] []

        Report.Failure ->
            Html.node "iron-icon" [ attribute "icon" "error", Attr.class "eventstatus-failure" ] []

        Report.Noop ->
            Html.node "iron-icon" [ attribute "icon" "done", Attr.class "eventstatus-noop" ] []

        Report.Skipped ->
            Html.node "iron-icon" [ attribute "icon" "block", Attr.class "eventstatus-skipped" ] []
