module Route.Report exposing (..)

import UrlParser


type Tab
    = Events
    | Logs
    | Metrics


fromIndex : Int -> Tab
fromIndex index =
    case index of
        0 ->
            Events

        1 ->
            Logs

        2 ->
            Metrics

        _ ->
            Events


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
