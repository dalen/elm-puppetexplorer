module Pagination exposing (..)

import Html
import Html.Attributes as Attributes
import Html.Events as Events


type alias Config msg =
    { activePage : Int
    , items : Int
    , maxButtons : Maybe Int
    , ellipsis : Maybe String
    , first : Maybe String
    , last : Maybe String
    , prev : Maybe String
    , next : Maybe String
    , onClick : Int -> msg
    }


config : (Int -> msg) -> Config msg
config msg =
    { activePage = 1
    , items = 1
    , maxButtons = Nothing
    , ellipsis = Just "..."
    , first = Just "«"
    , last = Just "»"
    , prev = Just "‹"
    , next = Just "›"
    , onClick = msg
    }


activePage : Int -> Config msg -> Config msg
activePage i config =
    { config | activePage = i }


items : Int -> Config msg -> Config msg
items i config =
    { config | items = i }


maxButtons : Int -> Config msg -> Config msg
maxButtons i config =
    { config | maxButtons = Just i }


first : Maybe String -> Config msg -> Config msg
first str config =
    { config | first = str }


last : Maybe String -> Config msg -> Config msg
last str config =
    { config | last = str }


prev : Maybe String -> Config msg -> Config msg
prev str config =
    { config | prev = str }


next : Maybe String -> Config msg -> Config msg
next str config =
    { config | next = str }


view : Config msg -> Html.Html msg
view config =
    nav
        (firstButton config
            ++ prevButton config
            ++ List.map (pageButton config) (List.range 1 config.items)
            ++ nextButton config
            ++ lastButton config
        )


button : String -> Bool -> Bool -> msg -> Html.Html msg
button text active disabled msg =
    Html.li
        [ Attributes.classList
            [ ( "page-item", True )
            , ( "active", active )
            , ( "disabled", disabled )
            ]
        , Events.onClick msg
        ]
        [ Html.span [ Attributes.class "page-link" ] [ Html.text text ]
        ]


nav : List (Html.Html msg) -> Html.Html msg
nav buttons =
    Html.nav [] [ Html.ul [ Attributes.class "pagination" ] buttons ]



-- Helper functions


pageButton : Config msg -> Int -> Html.Html msg
pageButton config page =
    button (toString page) (config.activePage == page) False (config.onClick page)


firstButton : Config msg -> List (Html.Html msg)
firstButton config =
    case config.first of
        Just first ->
            [ button first False (config.activePage == 1) (config.onClick 1) ]

        Nothing ->
            []


lastButton : Config msg -> List (Html.Html msg)
lastButton config =
    case config.last of
        Just last ->
            [ button last False (config.activePage == config.items) (config.onClick config.items) ]

        Nothing ->
            []


prevButton : Config msg -> List (Html.Html msg)
prevButton config =
    case config.prev of
        Just prev ->
            [ button prev False (config.activePage == 1) (config.onClick (config.activePage - 1)) ]

        Nothing ->
            []


nextButton : Config msg -> List (Html.Html msg)
nextButton config =
    case config.next of
        Just next ->
            [ button next False (config.activePage == config.items) (config.onClick (config.activePage + 1)) ]

        Nothing ->
            []
