module Types exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar
import Bootstrap.Card
import Http
import Dict


type alias Model =
    { config : Maybe Config
    , messages : List String
    , menubar : Bootstrap.Navbar.State
    , route : Route
    , dashboardPanels : DashboardPanelValues
    }


type Route
    = DashboardRoute (Maybe String)
    | NodeListRoute (Maybe String)


type Msg
    = NavbarMsg Bootstrap.Navbar.State
    | UpdateQueryMsg String
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | UpdateConfigMsg (Result Http.Error Config)
    | UpdateDashboardPanel Int Int (Result Http.Error Float)
    | NoopMsg


type alias Config =
    { serverUrl : String
    , nodeFacts : List String
    , unresponsiveHours : Int
    , dashboardPanels : List (List DashboardPanelConfig)
    }


type alias DashboardPanelConfig =
    { title : String
    , bean : String
    , style : Bootstrap.Card.CardOption Msg
    , multiply : Maybe Float
    , unit : Maybe String
    , value : Maybe Float
    }


type alias DashboardPanel =
    { config : DashboardPanelConfig
    , value : Maybe Float
    }


type alias DashboardPanelValues =
    Dict.Dict ( Int, Int ) Float
