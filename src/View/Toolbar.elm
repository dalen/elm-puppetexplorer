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


{-| Add The drawer button and loading indicator.
In between we either add a title or some custom Html
-}
view : Toolbar msg -> Html msg
view toolbar =
    App.toolbar []
        (Paper.iconButton [ icon "menu", attribute "drawer-toggle" "" ] []
            :: (case toolbar of
                    Title title ->
                        titleView title

                    Custom html ->
                        html
               )
        )


titleView : String -> List (Html m)
titleView title =
    [ Html.div [ attribute "main-title" "" ] [ text title ]
    ]


map : (a -> b) -> Toolbar a -> Toolbar b
map function toolbar =
    case toolbar of
        Custom html ->
            Custom (List.map (Html.map function) html)

        Title title ->
            Title title
