module Types exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar


type alias Model =
    { string : String
    , menubar : Bootstrap.Navbar.State
    , route : Route
    , dashboard :
        { panels : List DashboardPanel
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
    , style :
        String

    -- FIXME: create type for style
    , multiply : Maybe Float
    , unit : Maybe String
    }
