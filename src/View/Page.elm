module View.Page exposing (ActivePage(..), Page, map, frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (Html, text)
import Html.Attributes as Attr exposing (attribute)
import Route
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
        [ Paper.iconItem [ boolProperty "focused" isActive ]
            [ Html.node "iron-icon" [ attribute "slot" "item-icon", attribute "icon" icon ] []
            , text label
            ]
        ]


frame : Bool -> Maybe String -> ActivePage -> Page msg -> Html.Html msg
frame loading query activePage page =
    App.drawerLayout []
        [ App.drawer [ attribute "slot" "drawer", Attr.id "drawer" ]
            [ navLink "icons:dashboard" "Dashboard" (activePage == Dashboard) (Route.toString (Route.Dashboard { query = query }))
            , navLink "device:storage" "Nodes" (activePage == Nodes) (Route.toString (Route.NodeList { query = query }))
            ]
        , App.headerLayout [ attribute "fullbleed" "" ]
            [ App.header [ attribute "slot" "header", boolProperty "reveals" True ]
                [ App.toolbar [] (toolbar loading page.title)
                ]
            , page.content
            ]
        ]


toolbar : Bool -> String -> List (Html m)
toolbar loading title =
    [ Paper.iconButton [ icon "menu", attribute "drawer-toggle" "" ] []
    , Html.div [ attribute "main-title" "" ] [ text title ]
    , Paper.progress [ attribute "indeterminate" "", attribute "bottom-item" "", boolProperty "disabled" (not loading) ] []
    ]


map : (a -> b) -> { c | content : a } -> { c | content : b }
map function page =
    { page | content = function page.content }
