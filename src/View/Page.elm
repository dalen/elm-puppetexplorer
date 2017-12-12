module View.Page exposing (ActivePage(..), Page, frame, addLoading)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (Html, text)
import Html.Attributes as Attr exposing (attribute)
import View.Toolbar as Toolbar
import Bootstrap.Navbar as Navbar
import FontAwesome.Web as Icon
import Route


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
    , content : Html msg
    }


itemLink : ActivePage -> ActivePage -> (List (Html.Attribute msg) -> List (Html msg) -> Navbar.Item msg)
itemLink activePage linkPage =
    if activePage == linkPage then
        Navbar.itemLinkActive
    else
        Navbar.itemLink


frame : (Navbar.State -> msg) -> Navbar.State -> ActivePage -> Page msg -> Html.Html msg
frame navbarMsg navbarState activePage page =
    let
        toolbar =
            case page.toolbar of
                Toolbar.Title title ->
                    Navbar.config navbarMsg
                        |> Navbar.withAnimation
                        |> Navbar.brand []
                            [ text title ]
                        |> Navbar.items
                            [ itemLink activePage Dashboard [ Attr.href (Route.toString Route.Dashboard) ] [ Icon.dashboard, text " ", text "Dashboard" ]
                            , itemLink activePage Nodes [ Attr.href (Route.toString (Route.NodeList { query = Nothing })) ] [ Icon.tasks, text " ", text "Nodes" ]
                            ]
                        |> Navbar.view navbarState

                Toolbar.Custom custom ->
                    Navbar.config navbarMsg
                        |> custom
                        |> Navbar.view navbarState
    in
        Html.div []
            [ toolbar
            , page.content
            ]


{-| Set loading to true if argument is true or if it already was true in the Page
-}
addLoading : Bool -> Page msg -> Page msg
addLoading loading page =
    { page | loading = page.loading || loading }
