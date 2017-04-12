module Types exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar
import Bootstrap.Card
import Http


type alias Model =
    { menubar : Bootstrap.Navbar.State
    , route : Route
    , dashboardPanels : List (List DashboardPanel)
    }


type Route
    = DashboardRoute (Maybe String)
    | NodeListRoute (Maybe String)


type Msg
    = NavbarMsg Bootstrap.Navbar.State
    | UpdateQueryMsg String
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | FetchDashboardPanels
    | UpdateDashboardPanel Int Int (Result Http.Error Float)
    | NoOpMsg


type alias DashboardPanel =
    { title : String
    , bean : String
    , style : Bootstrap.Card.CardOption Msg
    , multiply : Maybe Float
    , unit : Maybe String
    , value : Maybe Float
    }
