module Types exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar


type alias Model =
    { string : String
    , menubar : Bootstrap.Navbar.State
    , route : Maybe Route
    }


type Route
    = Dashboard (Maybe String)
    | NodeList (Maybe String)


type Msg
    = NavbarMsg Bootstrap.Navbar.State
    | UpdateQuery String
    | NewUrl String
    | LocationChange Location
    | NoOp
