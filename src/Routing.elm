module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Erl
import Html
import Html.Attributes
import Events


type alias DashboardRouteParams =
    { query : Maybe String
    }


type alias NodeListRouteParams =
    { query : Maybe String
    }


type alias NodeDetailRouteParams =
    { node : String
    , page : Maybe Int
    , query : Maybe String
    }


type alias ReportRouteParams =
    { hash : String
    , page : Maybe Int
    , query : Maybe String
    }


type Route
    = DashboardRoute DashboardRouteParams
    | NodeListRoute DashboardRouteParams
    | NodeDetailRoute NodeDetailRouteParams
    | ReportRoute ReportRouteParams


parse : Location -> Route
parse location =
    Maybe.withDefault (DashboardRoute (DashboardRouteParams Nothing)) (parsePath route location)


route : Parser (Route -> a) a
route =
    oneOf
        [ map DashboardRoute (map DashboardRouteParams (s "" <?> stringParam "query"))
        , map NodeListRoute (map NodeListRouteParams (s "nodes" <?> stringParam "query"))
        , map NodeDetailRoute (map NodeDetailRouteParams (s "nodes" </> string <?> intParam "page" <?> stringParam "query"))
        , map ReportRoute (map ReportRouteParams (s "report" </> string <?> intParam "page" <?> stringParam "query"))
        ]


routeToErlUrl : Route -> Erl.Url
routeToErlUrl route =
    case route of
        DashboardRoute params ->
            Erl.parse "/"
                |> addParam "query" params.query

        NodeListRoute params ->
            Erl.parse "/nodes"
                |> addParam "query" params.query

        NodeDetailRoute params ->
            Erl.parse "/nodes"
                |> Erl.appendPathSegments [ params.node ]
                |> addParam "page" (Maybe.map Basics.toString params.page)
                |> addParam "query" params.query

        ReportRoute params ->
            Erl.parse "/report"
                |> Erl.appendPathSegments [ params.hash ]
                |> addParam "page" (Maybe.map Basics.toString params.page)
                |> addParam "query" params.query


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


newUrl : Route -> Cmd msg
newUrl route =
    Navigation.newUrl (toString route)


link : Route -> (Route -> msg) -> List (Html.Html msg) -> Html.Html msg
link route msg =
    Html.a (linkAttributes route msg)


{-| List of attributes for a link that has a href and an onClick handler
that creates a NewUrl message
-}
linkAttributes : Route -> (Route -> msg) -> List (Html.Attribute msg)
linkAttributes route msg =
    [ Html.Attributes.href (toString route)
    , (Events.onClickPreventDefault (msg route))
    ]
