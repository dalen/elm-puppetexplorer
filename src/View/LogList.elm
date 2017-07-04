module View.LogList exposing (view)

import Html exposing (Html, text)
import Date exposing (Date)
import PuppetDB.Report as Report
import Material.List as Lists
import Material.Icon as Icon
import Material.Color as Color
import Util


view : Date -> List Report.Log -> Html msg
view date logs =
    Lists.ul []
        (List.map (itemView date) logs)


itemView : Date -> Report.Log -> Html msg
itemView date log =
    Lists.li [ Lists.withBody ]
        [ Lists.content []
            [ text log.source
            , Lists.body [] [ text ((Util.time log.time) ++ " - " ++ log.message) ]
            ]
        , Lists.content2 []
            [ Lists.info2 []
                [ text log.level
                ]
            , (case log.level of
                "crit" ->
                    Icon.view "important" []

                "emerg" ->
                    Icon.view "important" []

                "alert" ->
                    Icon.view "important" []

                "err" ->
                    Icon.view "error" []

                "warning" ->
                    Icon.view "warning" []

                "notice" ->
                    Icon.view "notifications" [ Color.text Color.primary ]

                "info" ->
                    Icon.view "info" []

                "debug" ->
                    Icon.view "help" []

                _ ->
                    text ""
              )
            ]
        ]
