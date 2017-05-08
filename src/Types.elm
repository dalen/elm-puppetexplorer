module Types exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar
import Dict
import Date
import Time
import RemoteData exposing (WebData)
import NodeDetail
import NodeList
import Status exposing (Status)
import Config exposing (Config, DashboardPanelConfig)
import Routing exposing (Route)


type alias Model =
    { config : Config
    , messages : List String
    , menubar : Bootstrap.Navbar.State
    , route : Route
    , dashboardPanels : DashboardPanelValues
    , nodeList : NodeList.Model
    , nodeDetail : NodeDetail.Model
    , date : Date.Date
    }


type Msg
    = NavbarMsg Bootstrap.Navbar.State
    | TimeMsg Time.Time
    | UpdateQueryMsg String
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | UpdateDashboardPanel Int Int (WebData Float)
    | NodeListMsg NodeList.Msg
    | NodeDetailMsg NodeDetail.Msg
    | NoopMsg


type alias DashboardPanel =
    { config : DashboardPanelConfig
    , value : Maybe (WebData Float) -- FIXME: Maybe WebData is pretty convoluted
    }


type alias DashboardPanelValues =
    Dict.Dict ( Int, Int ) (WebData Float)


type alias NodeReportListItem =
    { reportTimestamp : Maybe Date.Date
    , status : Status
    }
