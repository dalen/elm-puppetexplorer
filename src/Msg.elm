module Msg exposing (Msg(..))

import Navigation exposing (Location)
import Route exposing (Route)
import Page.Dashboard as Dashboard
import Page.NodeDetail as NodeDetail
import Page.NodeList as NodeList
import Page.Report as Report
import Page.Errored as Errored exposing (PageLoadError)
import Time
import Material
import Bootstrap.Navbar as Navbar
import Bootstrap.Dropdown as Dropdown


type Msg
    = Mdl (Material.Msg Msg)
    | NavbarMsg Navbar.State
    | SearchDropdownMsg Dropdown.State
    | TimeMsg Time.Time
    | NewUrlMsg Route
    | LocationChangeMsg Location
    | DashboardLoaded (Result PageLoadError Dashboard.Model)
    | NodeListLoaded Route.NodeListParams (Result PageLoadError NodeList.Model)
    | NodeDetailLoaded Route.NodeDetailParams (Result PageLoadError NodeDetail.Model)
    | ReportLoaded Route.ReportParams (Result PageLoadError Report.Model)
    | DashboardMsg Never
    | NodeListMsg NodeList.Msg
    | NodeDetailMsg NodeDetail.Msg
    | ReportMsg Report.Msg
    | ScrollMsg Int
    | Noop
