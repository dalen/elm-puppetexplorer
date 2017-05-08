module Types exposing (..)

import Navigation exposing (Location)
import Bootstrap.Navbar
import Dict
import Date
import Time
import RemoteData exposing (WebData)
import Dashboard
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
    , dashboard : Dashboard.Model
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
    | DashboardMsg Dashboard.Msg
    | NodeListMsg NodeList.Msg
    | NodeDetailMsg NodeDetail.Msg
    | NoopMsg
