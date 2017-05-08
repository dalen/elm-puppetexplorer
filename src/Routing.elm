module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Erl
import Html
import Html.Attributes
import Events


type Route
    = DashboardRoute (Maybe String)
    | NodeListRoute (Maybe String)
    | NodeDetailRoute String (Maybe Int) (Maybe String)


parse : Location -> Route
parse location =
    Maybe.withDefault (DashboardRoute Nothing) (parsePath route location)


route : Parser (Route -> a) a
route =
    oneOf
        [ map DashboardRoute (s "" <?> stringParam "query")
        , map NodeListRoute (s "nodes" <?> stringParam "query")
        , map NodeDetailRoute (s "nodes" </> string <?> intParam "page" <?> stringParam "query")
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

        NodeDetailRoute node page query ->
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
