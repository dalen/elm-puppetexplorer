module View.EventList exposing (view)

import Html exposing (Html, text)
import Date exposing (Date)
import PuppetDB.Report as Report
import Material.List as Lists
import Material.Icon as Icon
import Material.Color as Color
import ColorScheme


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
            Icon.view "check_circle" [ Color.text ColorScheme.success ]

        Report.Failure ->
            Icon.view "error" [ Color.text ColorScheme.error ]

        Report.Noop ->
            Icon.view "done" [ Color.text ColorScheme.unknown ]

        Report.Skipped ->
            Icon.view "block" [ Color.text ColorScheme.warning ]
