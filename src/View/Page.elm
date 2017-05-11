module View.Page exposing (ActivePage(..), frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html
import Html.Events
import Routing
import Events
import Bootstrap.Form.Input as Input
import Bootstrap.Form.InputGroup as InputGroup
import Bootstrap.Navbar as Navbar
import Bootstrap.Grid as Grid
import FontAwesome.Web as Icon


{-| Determines which navbar link (if any) will be rendered as active.
Note that we don't enumerate every page here, because the navbar doesn't
have links for every page.
-}
type ActivePage
    = Dashboard
    | Nodes



-- FIXME: WAY too many parameters


frame : Maybe String -> (String -> msg) -> (String -> msg) -> (Routing.Route -> msg) -> Navbar.State -> (Navbar.State -> msg) -> ActivePage -> Html.Html msg -> Html.Html msg
frame query updateQueryMsg submitQueryMsg newUrlMsg navbarState navbarMsg page content =
    Html.div []
        [ searchField query updateQueryMsg submitQueryMsg
        , navbar query page newUrlMsg navbarState navbarMsg
        , Grid.containerFluid [] [ content ]
        ]


navbar : Maybe String -> ActivePage -> (Routing.Route -> msg) -> Navbar.State -> (Navbar.State -> msg) -> Html.Html msg
navbar query page routeMsg navbarState navbarMsg =
    Navbar.config navbarMsg
        |> Navbar.items
            [ navbarLink (page == Dashboard) (Routing.DashboardRoute (Routing.DashboardRouteParams query)) [ Icon.tachometer, Html.text " ", Html.text "Dashboard" ]
            , navbarLink (page == Nodes) (Routing.NodeListRoute (Routing.NodeListRouteParams query)) [ Icon.server, Html.text " ", Html.text "Nodes" ]
            ]
        |> Navbar.view navbarState


navbarLink : Bool -> Routing.Route -> List (Html.Html msg) -> Navbar.Item msg
navbarLink isActive route content =
    (case isActive of
        True ->
            Navbar.itemLinkActive

        False ->
            Navbar.itemLink
    )
        [ Routing.href route ]
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
            [ InputGroup.span [] [ Icon.search ]
            , InputGroup.span [] [ Html.text "inventory {" ]
            ]
        |> InputGroup.successors
            [ InputGroup.span [] [ Html.text "}" ]
            ]
        |> InputGroup.view
