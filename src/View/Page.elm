module View.Page exposing (ActivePage(..), Page, map, frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import Html exposing (Html, text)
import Html.Attributes as Attributes
import Route
import Material
import Material.Layout as Layout
import Material.Icon as Icon
import Material.Spinner as Spinner
import Material.Options as Options
import Material.Color as Color
import Material.Button as Button
import Material.List as Lists


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
    Html.a [ Attributes.href href ]
        [ Lists.li []
            [ Lists.content []
                [ Lists.avatarIcon icon []
                , Options.span [ Color.text Color.accent |> Options.when isActive ] [ text label ]
                ]
            ]
        ]


frame : Bool -> Maybe String -> (Material.Msg msg -> msg) -> Material.Model -> ActivePage -> Page msg -> Html.Html msg
frame loading query materialMsg model activePage page =
    let
        materialNavLink =
            navLink
    in
        Layout.render materialMsg
            model
            [ Layout.fixedDrawer
            , Layout.fixedHeader
            ]
            { header = [ header page.title ]
            , drawer =
                [ Layout.title [] [ Html.text "Puppet Explorer" ]
                , Layout.navigation []
                    [ Lists.ul []
                        [ materialNavLink "dashboard" "Dashboard" (activePage == Dashboard) (Route.toString (Route.Dashboard { query = query }))
                        , materialNavLink "storage" "Nodes" (activePage == Nodes) (Route.toString (Route.NodeList { query = query }))
                        ]
                    ]
                , Layout.spacer
                , Layout.row [] [ Spinner.spinner [ Spinner.active loading ] ]
                ]
            , tabs =
                ( [], [] )
            , main = [ page.content ]
            }


header : String -> Html m
header title =
    Layout.row
        []
        [ Layout.title [] [ text title ]
        , Layout.spacer
        , Layout.navigation []
            []
        ]


map : (a -> b) -> { c | content : a } -> { c | content : b }
map function page =
    { page | content = function page.content }



{- }

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

-}
