module View.Page exposing (ActivePage(..), Page, map, frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (Html, text)
import Html.Attributes as Attr exposing (attribute)
import Route
import Material
import Material.Options as Options
import Material.Color as Color
import Material.List as Lists
import Polymer.App as App
import Polymer.Paper as Paper
import Polymer.Attributes exposing (icon, boolProperty)


{-| Determines which navbar link (if any) will be rendered as active.
Note that we don't enumerate every page here, because the navbar doesn't
have links for every page.
-}
type ActivePage
    = Dashboard
    | Nodes
    | Other


type alias Page msg =
    { title : String
    , content : Html msg
    }


navLink : String -> String -> Bool -> String -> Html msg
navLink icon label isActive href =
    Html.a [ Attr.href href ]
        [ Lists.li [ Color.background (Color.color Color.Grey Color.S200) |> Options.when isActive ]
            [ Lists.content []
                [ Lists.icon icon [ Color.background Color.primary |> Options.when isActive, Color.text (Color.color Color.Grey Color.S200) |> Options.when isActive ]
                , Options.span [ Color.text Color.primary |> Options.when isActive ] [ text label ]
                ]
            ]
        ]


frame : Bool -> Maybe String -> (Material.Msg msg -> msg) -> Material.Model -> ActivePage -> Page msg -> Html.Html msg
frame loading query materialMsg model activePage page =
    App.drawerLayout []
        [ App.drawer [ attribute "slot" "drawer", Attr.id "drawer" ] [ text "foo" ]
        , App.headerLayout [ attribute "fullbleed" "" ]
            [ App.header [ attribute "slot" "header", boolProperty "reveals" True ]
                [ App.toolbar [] (toolbar loading page.title)
                ]
            , page.content
            ]
        ]



{-
   Layout.render
   materialMsg
   model
   [ Layout.fixedDrawer
   , Layout.fixedHeader
   ]
   { header = [ header loading page.title ]
   , drawer =
       [ Layout.title [] [ Html.text "Puppet Explorer" ]
       , Layout.navigation []
           [ Lists.ul [ Options.cs "mt-0", Options.cs "pt-0" ]
               [ navLink "dashboard" "Dashboard" (activePage == Dashboard) (Route.toString (Route.Dashboard { query = query }))
               , navLink "storage" "Nodes" (activePage == Nodes) (Route.toString (Route.NodeList { query = query }))
               ]
           ]
       ]
   , tabs =
       ( [], [] )
   , main = [ page.content ]
   }
-}


toolbar : Bool -> String -> List (Html m)
toolbar loading title =
    [ Paper.iconButton [ icon "menu", attribute "drawer-toggle" "" ] []
    , Html.div [ attribute "main-title" "" ] [ text title ]
    , Paper.progress [ attribute "indeterminate" "", attribute "bottom-item" "", boolProperty "disabled" (not loading) ] []
    ]



{- }
   Layout.row
       []
       [ Layout.title [] [ text title ]
       , Layout.spacer
       , Paper.spinner [ A.boolProperty "active" loading ] []
       ]
-}


map : (a -> b) -> { c | content : a } -> { c | content : b }
map function page =
    { page | content = function page.content }
