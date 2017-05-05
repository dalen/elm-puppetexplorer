module Routing exposing (parse, getQueryParam, toString)

import Navigation exposing (Location)
import Types exposing (..)
import UrlParser exposing (..)
import Erl


parse : Location -> Route
parse location =
    Maybe.withDefault (DashboardRoute Nothing) (parsePath route location)


getQueryParam : Route -> Maybe String
getQueryParam route =
    case route of
        DashboardRoute query ->
            query

        NodeListRoute query ->
            query

        NodeDetailRoute _ query ->
            query


route : Parser (Route -> a) a
route =
    oneOf
        [ map DashboardRoute (s "" <?> stringParam "query")
        , map NodeListRoute (s "nodes" <?> stringParam "query")
        , map NodeDetailRoute (s "nodes" </> string <?> stringParam "query")
        ]


routeToErlUrl : Route -> Erl.Url
routeToErlUrl route =
    case route of
        DashboardRoute query ->
            Erl.parse "/"
                |> addParam "query" query

        NodeListRoute query ->
            Erl.parse "/nodes"
                |> addParam "query" query

        NodeDetailRoute node query ->
            Erl.parse "/nodes"
                |> Erl.appendPathSegments [ node ]
                |> addParam "query" query


addParam : String -> Maybe String -> Erl.Url -> Erl.Url
addParam key value url =
    case value of
        Just p ->
            url
                |> Erl.addQuery key p

        Nothing ->
            url


toString : Route -> String
toString route =
    Erl.toString (routeToErlUrl route)
