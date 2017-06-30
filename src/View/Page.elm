module View.Page exposing (ActivePage(..), Page, map, frame, addLoading)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (Html, text)
import Html.Attributes as Attr exposing (attribute)
import Route
import View.Toolbar as Toolbar
import Polymer.App as App
import Polymer.Paper as Paper
import Polymer.Attributes exposing (icon, boolProperty)
import Material.Layout as Layout
import Material


{-| Determines which navbar link (if any) will be rendered as active.
Note that we don't enumerate every page here, because the navbar doesn't
have links for every page.
-}
type ActivePage
    = Dashboard
    | Nodes
    | Other


type alias Page msg =
    { loading : Bool
    , toolbar : Toolbar.Toolbar msg
    , extraToolbar : Maybe (Html msg)
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


frame : Material.Model -> ActivePage -> Page msg -> Html.Html msg
frame mdl activePage page =
    let
        toolbar =
            Toolbar.view page.toolbar

        progressBar =
            Paper.progress
                [ attribute "indeterminate" ""
                , attribute "bottom-item" ""
                , boolProperty "disabled" (not page.loading)
                ]
                []
    in
        App.drawerLayout []
            [ App.drawer [ attribute "slot" "drawer", Attr.id "drawer" ]
                [ App.toolbar [] []
                , navLink "icons:dashboard" "Dashboard" (activePage == Dashboard) (Route.toString Route.Dashboard)
                , navLink "device:storage" "Nodes" (activePage == Nodes) (Route.toString (Route.NodeList { query = Nothing }))
                ]
            , App.headerLayout
                [ attribute "fullbleed" "" ]
                [ App.header
                    [ attribute "slot" "header"
                    , boolProperty "reveals" True
                    ]
                    (case page.extraToolbar of
                        Nothing ->
                            [ toolbar, progressBar ]

                        Just extraToolbar ->
                            [ toolbar, extraToolbar, progressBar ]
                    )
                , page.content
                ]
            ]


map : (a -> b) -> Page a -> Page b
map function page =
    { page
        | content = Html.map function page.content
        , toolbar = Toolbar.map function page.toolbar
        , extraToolbar = Maybe.map (Html.map function) page.extraToolbar
    }


{-| Set loading to true if argument is true or if it already was true in the Page
-}
addLoading : Bool -> Page msg -> Page msg
addLoading loading page =
    { page | loading = page.loading || loading }
