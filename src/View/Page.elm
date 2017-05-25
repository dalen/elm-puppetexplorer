module View.Page exposing (ActivePage(..), frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (Html, text)
import Html.Attributes as Attributes
import Html.Events
import Route
import Events
import Material
import Material.Layout as Layout
import Material.List as Lists
import Material.Icon as Icon
import Material.Options as Options
import Material.Spinner as Spinner
import Bootstrap.Form.Input as Input
import Bootstrap.Form.InputGroup as InputGroup
import Bootstrap.Navbar as Navbar
import View.Spinner


{-| Determines which navbar link (if any) will be rendered as active.
Note that we don't enumerate every page here, because the navbar doesn't
have links for every page.
-}
type ActivePage
    = Dashboard
    | Nodes
    | Other



-- FIXME: WAY too many parameters


frame : Bool -> Maybe String -> (Int -> msg) -> (Material.Msg msg -> msg) -> Material.Model -> ActivePage -> Html.Html msg -> Html.Html msg
frame loading query selectTabMsg materialMsg model page content =
    let
        selectedTab =
            case page of
                Dashboard ->
                    0

                Nodes ->
                    1

                _ ->
                    3
    in
        Layout.render materialMsg
            model
            [ Layout.selectedTab selectedTab
            , Layout.onSelectTab selectTabMsg
            , Layout.fixedDrawer
            ]
            { header = []
            , drawer =
                [ Layout.title [] [ Html.text "Puppet Explorer" ]
                , Layout.navigation []
                    [ Lists.ul []
                        [ Lists.li []
                            [ Lists.content []
                                [ Layout.link [ Layout.href (Route.toString (Route.Dashboard { query = query })) ]
                                    [ Lists.icon "dashboard" []
                                    , text "Dashboard"
                                    ]
                                ]
                            , Lists.li []
                                [ Lists.content []
                                    [ Layout.link [ Layout.href (Route.toString (Route.NodeList { query = query })) ]
                                        [ Lists.icon "storage" []
                                        , text "Nodes"
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                , Layout.spacer
                , Layout.row [] [ Spinner.spinner [ Spinner.active loading ] ]
                ]
            , tabs =
                ( [], [] )
            , main = [ content ]
            }


navbar : Bool -> Maybe String -> ActivePage -> (Route.Route -> msg) -> Navbar.State -> (Navbar.State -> msg) -> Html.Html msg
navbar loading query page routeMsg navbarState navbarMsg =
    Navbar.config navbarMsg
        |> Navbar.items
            [ navbarLink (page == Dashboard) (Route.Dashboard (Route.DashboardParams query)) [ Icon.i "dashboard", Html.text " ", Html.text "Dashboard" ]
            , navbarLink (page == Nodes) (Route.NodeList (Route.NodeListParams query)) [ Icon.i "dashboard", Html.text " ", Html.text "Nodes" ]
            ]
        |> Navbar.customItems
            [ Navbar.textItem []
                (if loading then
                    [ View.Spinner.view ]
                 else
                    []
                )
            ]
        |> Navbar.view navbarState


navbarLink : Bool -> Route.Route -> List (Html.Html msg) -> Navbar.Item msg
navbarLink isActive route content =
    (case isActive of
        True ->
            Navbar.itemLinkActive

        False ->
            Navbar.itemLink
    )
        [ Route.href route ]
        content


searchField : Maybe String -> (String -> msg) -> (String -> msg) -> Html.Html msg
searchField query updateQueryMsg submitQueryMsg =
    -- FIXME: use query?
    InputGroup.config
        (InputGroup.search
            [ Input.attrs [ Html.Events.onInput updateQueryMsg, Events.onChange submitQueryMsg ]
            ]
        )
        |> InputGroup.predecessors
            [ InputGroup.span [] [ Icon.i "search" ]
            , InputGroup.span [] [ text "inventory {" ]
            ]
        |> InputGroup.successors
            [ InputGroup.span [] [ text "}" ]
            ]
        |> InputGroup.view
