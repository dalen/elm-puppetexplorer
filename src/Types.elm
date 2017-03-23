module Types exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar


type alias Model =
    { string : String
    , menubar : Bootstrap.Navbar.State
    , route : Maybe Route
    , dashboard : List List DashboardPanel
    }


type Route
    = Dashboard (Maybe String)
    | NodeList (Maybe String)


type alias DashboardPanel =
    { title : String
    , bean : String
    , style :
        String
        -- FIXME: create type for style
    , multiply : Maybe Float
    , unit : Maybe String
    }


type Msg
    = NavbarMsg Bootstrap.Navbar.State
    | UpdateQuery String
    | NewUrl String
    | LocationChange Location
    | NoOp
