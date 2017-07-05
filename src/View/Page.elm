module View.Page exposing (ActivePage(..), Page, pageWithoutTabs, frame, addLoading)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (Html, text)
import Html.Attributes as Attr exposing (attribute)
import Route
import View.Toolbar as Toolbar
import Material
import Material.Options as Options
import Material.Layout as Layout
import Material.List as Lists
import Material.Progress as Progress
import Material.Color as Color


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
    , tabs : ( List (Html msg), List (Options.Style msg) )
    , selectedTab : Int
    , onSelectTab : Maybe (Int -> msg)
    , content : Html msg
    }


pageWithoutTabs : Bool -> Toolbar.Toolbar msg -> Html msg -> Page msg
pageWithoutTabs loading toolbar content =
    { loading = loading
    , toolbar = toolbar
    , tabs = ( [], [] )
    , selectedTab = 0
    , onSelectTab = Nothing
    , content = content
    }


navLink : String -> String -> Bool -> String -> Html msg
navLink icon label isActive href =
    Html.a [ Attr.href href ]
        [ Lists.li [ Color.background (Color.color Color.Grey Color.S200) |> Options.when isActive ]
            [ Lists.content []
                [ Lists.icon icon []
                , text label
                ]
            ]
        ]


frame : (Material.Msg msg -> msg) -> Material.Model -> ActivePage -> Page msg -> Html.Html msg
frame mdlMsg mdlModel activePage page =
    let
        toolbar =
            Toolbar.view page.toolbar

        progressBar =
            if page.loading then
                Progress.indeterminate
            else
                Progress.progress 100

        layoutOptions =
            [ Layout.fixedDrawer
            , Layout.fixedTabs
            , Layout.fixedHeader
            , Layout.selectedTab page.selectedTab
            , Layout.rippleTabs
            ]
    in
        Layout.render mdlMsg
            mdlModel
            (case page.onSelectTab of
                Just onSelectTab ->
                    (Layout.onSelectTab onSelectTab) :: layoutOptions

                Nothing ->
                    layoutOptions
            )
            { header = [ toolbar, progressBar ]
            , drawer =
                [ Lists.ul []
                    [ navLink "dashboard" "Dashboard" (activePage == Dashboard) (Route.toString Route.Dashboard)
                    , navLink "storage" "Nodes" (activePage == Nodes) (Route.toString (Route.NodeList { query = Nothing }))
                    ]
                ]
            , tabs = page.tabs
            , main = [ page.content ]
            }


{-| Set loading to true if argument is true or if it already was true in the Page
-}
addLoading : Bool -> Page msg -> Page msg
addLoading loading page =
    { page | loading = page.loading || loading }
