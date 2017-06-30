module View.Toolbar exposing (..)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (Html, text)
import Html.Attributes as Attr exposing (attribute)
import Route
import Material.Layout as Layout


type Toolbar msg
    = Title String
    | Custom (List (Html msg))


{-| Add The drawer button and loading indicator.
In between we either add a title or some custom Html
-}
view : Toolbar msg -> Html msg
view toolbar =
    Layout.row []
        (case toolbar of
            Title title ->
                [ Layout.title [] [ text title ] ]

            Custom html ->
                html
        )


map : (a -> b) -> Toolbar a -> Toolbar b
map function toolbar =
    case toolbar of
        Custom html ->
            Custom (List.map (Html.map function) html)

        Title title ->
            Title title
