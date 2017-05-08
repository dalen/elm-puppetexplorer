module Types exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar
import Dict
import Date
import Time
import RemoteData exposing (WebData)


type alias Model =
    { config : Config
    , messages : List String
    , menubar : Bootstrap.Navbar.State
    , route : Route
    , dashboardPanels : DashboardPanelValues
    , nodeList : WebData (List NodeListItem)
    , nodeReportList : WebData (List NodeReportListItem)
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
    | UpdateNodeReportListMsg (WebData (List NodeReportListItem))
    | UpdateNodeReportListCountMsg (WebData Int)
    | ChangePageMsg Int
    | TimeMsg Time.Time
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
    , style : String
    , multiply : Maybe Float
    , unit : Maybe String
    }


type alias DashboardPanel =
    { config : DashboardPanelConfig
    , value : Maybe (WebData Float) -- FIXME: Maybe WebData is pretty convoluted
    }


type alias DashboardPanelValues =
    Dict.Dict ( Int, Int ) (WebData Float)


type alias NodeListItem =
    { certname : String
    , reportTimestamp : Maybe Date.Date
    , latestReportStatus : NodeItemStatus
    }


type NodeItemStatus
    = Changed
    | Failed
    | Unchanged
    | Unknown


type alias NodeReportListItem =
    { reportTimestamp : Maybe Date.Date
    , status : NodeItemStatus
    }
