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
    Html.nav []
        [ Html.ul [ Attributes.class "pagination" ]
            (firstButton config
                ++ prevButton config
                ++ List.map (pageButton config) (List.range 1 config.items)
                ++ nextButton config
                ++ lastButton config
            )
        ]



-- Helper functions


pageButton : Config msg -> Int -> Html.Html msg
pageButton config page =
    Html.li
        [ Attributes.classList
            [ ( "page-item", True )
            , ( "active", config.activePage == page )
            ]
        , Events.onClick (config.onClick page)
        ]
        [ Html.span [ Attributes.class "page-link" ] [ Html.text (toString page) ]
        ]


firstButton : Config msg -> List (Html.Html msg)
firstButton config =
    case config.first of
        Just first ->
            [ Html.li
                [ Attributes.classList
                    [ ( "page-item", True )
                    , ( "disabled", config.activePage == 1 )
                    ]
                , Events.onClick (config.onClick 1)
                ]
                [ Html.span [ Attributes.class "page-link" ] [ Html.text first ]
                ]
            ]

        Nothing ->
            []


lastButton : Config msg -> List (Html.Html msg)
lastButton config =
    case config.last of
        Just last ->
            [ Html.li
                [ Attributes.classList
                    [ ( "page-item", True )
                    , ( "disabled", config.activePage == config.items )
                    ]
                , Events.onClick (config.onClick config.items)
                ]
                [ Html.span [ Attributes.class "page-link" ] [ Html.text last ]
                ]
            ]

        Nothing ->
            []


prevButton : Config msg -> List (Html.Html msg)
prevButton config =
    case config.prev of
        Just prev ->
            [ Html.li
                [ Attributes.classList
                    [ ( "page-item", True )
                    , ( "disabled", config.activePage == 1 )
                    ]
                , Events.onClick (config.onClick (config.activePage - 1))
                ]
                [ Html.span [ Attributes.class "page-link" ] [ Html.text prev ]
                ]
            ]

        Nothing ->
            []


nextButton : Config msg -> List (Html.Html msg)
nextButton config =
    case config.next of
        Just next ->
            [ Html.li
                [ Attributes.classList
                    [ ( "page-item", True )
                    , ( "disabled", config.activePage == config.items )
                    ]
                , Events.onClick (config.onClick (config.activePage + 1))
                ]
                [ Html.span [ Attributes.class "page-link" ] [ Html.text next ]
                ]
            ]

        Nothing ->
            []
