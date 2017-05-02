module Routing exposing (init, parse, getQueryParam, toString)

import Navigation exposing (Location)
import Types exposing (..)
import UrlParser exposing (..)
import Erl
import Dashboard
import NodeList


parse : Location -> Route
parse location =
    Maybe.withDefault (DashboardRoute Nothing) (parsePath route location)


{-| Initialize the current route
Can update (initialize) the model for the route as well
-}
init : Route -> Config -> Model -> ( Model, Cmd Msg )
init route config model =
    case route of
        DashboardRoute _ ->
            Dashboard.init config model

        NodeListRoute query ->
            NodeList.init config model


getQueryParam : Route -> Maybe String
getQueryParam route =
    case route of
        DashboardRoute query ->
            query

        NodeListRoute query ->
            query


route : Parser (Route -> a) a
route =
    oneOf
        [ map DashboardRoute (s "" <?> stringParam "query")
        , map NodeListRoute (s "nodes" <?> stringParam "query")
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
