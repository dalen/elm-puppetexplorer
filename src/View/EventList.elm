module View.EventList exposing (view)

import Html exposing (Html, text)
import Date exposing (Date)
import PuppetDB.Report as Report
import Material.List as Lists
import Material.Icon as Icon
import Material.Color as Color


view : Date -> Maybe (List Report.Event) -> Html msg
view date eventList =
    case eventList of
        Just events ->
            Lists.ul []
                (List.map (itemView date) events)

        Nothing ->
            Html.div [] [ text "No events found" ]


itemView : Date -> Report.Event -> Html msg
itemView date event =
    let
        truncatedTitle =
            if String.length event.resourceTitle > 60 then
                "..." ++ (String.right 60 event.resourceTitle)
            else
                event.resourceTitle
    in
        Lists.li [ Lists.withBody ]
            -- NB! Required on every Lists.li containing subtitle.
            [ Lists.content []
                [ text (event.resourceType ++ "[" ++ truncatedTitle ++ "]")
                , Lists.body [] [ text (Maybe.withDefault "" event.message) ]
                ]
            , Lists.content2 []
                [ statusIcon event.status
                ]
            ]


statusIcon : Report.EventStatus -> Html msg
statusIcon status =
    case status of
        Report.Success ->
            Icon.view "check_circle" [ Color.text (Color.color Color.Green Color.S500) ]

        Report.Failure ->
            Icon.view "error" [ Color.text (Color.color Color.DeepOrange Color.A700) ]

        Report.Noop ->
            Icon.view "done" [ Color.text (Color.color Color.Grey Color.S500) ]

        Report.Skipped ->
            Icon.view "block" [ Color.text (Color.color Color.Yellow Color.S500) ]
