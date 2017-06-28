module Route exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Erl
import Html
import Html.Attributes
import Regex
import Route.Report


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
    , tab : Route.Report.Tab
    }


type Route
    = Dashboard
    | NodeList NodeListParams
    | NodeDetail NodeDetailParams
    | Report ReportParams



-- TODO: move search part to search if it is in the hash


hashLocation : Location -> Location
hashLocation location =
    let
        newPath =
            Regex.replace
                Regex.All
                (Regex.regex "^[/#]*")
                (\_ -> "/")
                (String.concat [ location.pathname, location.hash ])
    in
        Debug.log "location" { location | pathname = newPath, hash = "" }


parse : Location -> Maybe Route
parse location =
    parseHash route location


route : Parser (Route -> a) a
route =
    oneOf
        [ map Dashboard (s "")
        , map NodeList (map NodeListParams (s "nodes" <?> stringParam "query"))
        , map NodeDetail
            (map NodeDetailParams
                (s "nodes" </> string <?> intParam "page" <?> stringParam "query")
            )
        , map Report
            (map
                ReportParams
                (s "report" </> string </> Route.Report.parser)
            )
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
        Dashboard ->
            Erl.parse "#/"

        NodeList params ->
            Erl.parse "#/nodes"
                |> addParam "query" params.query

        NodeDetail params ->
            Erl.parse ("#/nodes/" ++ params.node)
                |> addParam "page" (Maybe.map Basics.toString params.page)
                |> addParam "query" params.query

        Report params ->
            Erl.parse ("#/report/" ++ params.hash ++ "/" ++ (Route.Report.toPath params.tab))
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
