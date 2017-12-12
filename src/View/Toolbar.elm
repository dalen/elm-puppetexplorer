module View.Toolbar exposing (..)

import Html exposing (Html, text)
import Bootstrap.Navbar as Navbar


type Toolbar msg
    = Title String
    | Custom (Navbar.Config msg -> Navbar.Config msg)


{-| Add The drawer button and loading indicator.
In between we either add a title or some custom Html
-}
view : (Navbar.State -> msg) -> Navbar.State -> Bool -> Toolbar msg -> Html msg
view navbarMsg navbarState loading toolbar =
    case toolbar of
        Title title ->
            Navbar.config navbarMsg
                |> Navbar.withAnimation
                |> Navbar.brand []
                    [ text title ]
                |> Navbar.view navbarState

        Custom custom ->
            Navbar.config navbarMsg
                |> custom
                |> Navbar.view navbarState



{-
   map : (a -> b) -> Toolbar a -> Toolbar b
   map function toolbar =
       case toolbar of
           Custom html ->
               Custom (List.map (Html.map function) html)

           Title title ->
               Title title
-}
