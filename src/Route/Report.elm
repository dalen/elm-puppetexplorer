module Route.Report exposing (..)

import UrlParser


type Tab
    = Events
    | Logs
    | Metrics


toPath : Tab -> String
toPath tab =
    case tab of
        Events ->
            "events"

        Logs ->
            "logs"

        Metrics ->
            "metrics"


toIndex : Tab -> Int
toIndex tab =
    case tab of
        Events ->
            0

        Logs ->
            1

        Metrics ->
            2


parser : UrlParser.Parser (Tab -> c) c
parser =
    UrlParser.oneOf
        [ UrlParser.map Events (UrlParser.s "events")
        , UrlParser.map Logs (UrlParser.s "logs")
        , UrlParser.map Metrics (UrlParser.s "metrics")
        ]
