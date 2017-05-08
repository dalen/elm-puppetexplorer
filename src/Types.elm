module Types exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar
import Dict
import Date
import Time
import RemoteData exposing (WebData)
import NodeDetail
import Status exposing (Status)
import Config exposing (Config, DashboardPanelConfig)


type alias Model =
    { config : Config
    , messages : List String
    , menubar : Bootstrap.Navbar.State
    , route : Route
    , dashboardPanels : DashboardPanelValues
    , nodeList : WebData (List NodeListItem)
    , nodeDetail : NodeDetail.Model
    , date : Date.Date
    }


type Route
    = DashboardRoute (Maybe String)
    | NodeListRoute (Maybe String)
    | NodeDetailRoute String (Maybe Int) (Maybe String)


type Msg
    = NavbarMsg Bootstrap.Navbar.State
    | UpdateQueryMsg String
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | UpdateDashboardPanel Int Int (WebData Float)
    | UpdateNodeListMsg (WebData (List NodeListItem))
    | TimeMsg Time.Time
    | NodeDetailMsg NodeDetail.Msg
    | NoopMsg


type alias DashboardPanel =
    { config : DashboardPanelConfig
    , value : Maybe (WebData Float) -- FIXME: Maybe WebData is pretty convoluted
    }


type alias DashboardPanelValues =
    Dict.Dict ( Int, Int ) (WebData Float)


type alias NodeListItem =
    { certname : String
    , reportTimestamp : Maybe Date.Date
    , latestReportStatus : Status
    }


type alias NodeReportListItem =
    { reportTimestamp : Maybe Date.Date
    , status : Status
    }
