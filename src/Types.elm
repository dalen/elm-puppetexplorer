module Types exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar
import Bootstrap.Card


type alias Model =
    { string : String
    , menubar : Bootstrap.Navbar.State
    , route : Route
    , dashboard :
        { panels : List (List DashboardPanel)
        }
    }


type Route
    = DashboardRoute (Maybe String)
    | NodeListRoute (Maybe String)


type Msg
    = NavbarMsg Bootstrap.Navbar.State
    | UpdateQueryMsg String
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | NoOpMsg


type alias DashboardPanel =
    { title : String
    , bean : String
    , style : Bootstrap.Card.CardOption Msg
    , multiply : Maybe Float
    , unit : Maybe String
    , value : Maybe Float
    }
