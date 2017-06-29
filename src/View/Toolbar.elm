module View.Toolbar exposing (..)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (Html, text)
import Html.Attributes as Attr exposing (attribute)
import Route
import Polymer.App as App
import Polymer.Paper as Paper
import Polymer.Attributes exposing (icon, boolProperty)


type Toolbar msg
    = Title String
    | Custom (List (Html msg))


view : Bool -> Toolbar msg -> Html msg
view loading toolbar =
    App.toolbar []
        (case toolbar of
            Title title ->
                titleView loading title

            Custom html ->
                html
        )


titleView : Bool -> String -> List (Html m)
titleView loading title =
    [ Paper.iconButton [ icon "menu", attribute "drawer-toggle" "" ] []
    , Html.div [ attribute "main-title" "" ] [ text title ]
    , Paper.progress [ attribute "indeterminate" "", attribute "bottom-item" "", boolProperty "disabled" (not loading) ] []
    ]


map : (a -> b) -> Toolbar a -> Toolbar b
map function toolbar =
    case toolbar of
        Custom html ->
            Custom (List.map (Html.map function) html)

        Title title ->
            Title title
