module Route exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Erl
import Html
import Html.Attributes


type alias DashboardParams =
    { query : Maybe String
    }


type alias NodeListParams =
    { query : Maybe String
    }


type alias NodeDetailParams =
    { node : String
    , page : Maybe Int
    , query : Maybe String
    }


type alias ReportParams =
    { hash : String
    , page : Maybe Int
    , query : Maybe String
    }


type Route
    = Dashboard DashboardParams
    | NodeList NodeListParams
    | NodeDetail NodeDetailParams
    | Report ReportParams


parse : Location -> Maybe Route
parse location =
    parseHash route location


route : Parser (Route -> a) a
route =
    oneOf
        [ map Dashboard (map DashboardParams (s "" <?> stringParam "query"))
        , map NodeList (map NodeListParams (s "nodes" <?> stringParam "query"))
        , map NodeDetail (map NodeDetailParams (s "nodes" </> string <?> intParam "page" <?> stringParam "query"))
        , map Report (map ReportParams (s "report" </> string <?> intParam "page" <?> stringParam "query"))
        ]


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
    (case route of
        Dashboard params ->
            Erl.parse "#/"

        NodeList params ->
            Erl.parse "#/nodes"
                |> addParam "query" params.query

        NodeDetail params ->
            Erl.parse ("#/nodes/" ++ params.node)
                |> addParam "page" (Maybe.map Basics.toString params.page)
                |> addParam "query" params.query

        Report params ->
            Erl.parse ("#/report/" ++ params.hash)
                |> addParam "page" (Maybe.map Basics.toString params.page)
                |> addParam "query" params.query
    )
        |> Erl.toString


newUrl : Route -> Cmd msg
newUrl route =
    Navigation.newUrl (toString route)


modifyUrl : Route -> Cmd msg
modifyUrl route =
    Navigation.modifyUrl (toString route)


{-| }
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

-}
href : Route -> Html.Attribute msg
href route =
    Html.Attributes.href (toString route)
