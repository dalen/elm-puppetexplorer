module Data.Common exposing (Common, init)

import Date
import Date.Extra
import Config exposing (Config)
import Bootstrap.Navbar as Navbar


type alias Common =
    { config : Config
    , menubar : Navbar.State
    , queryField : String
    }


init : Config -> ( Common, Cmd msg )
init config =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg
    in
        ( { date = Date.Extra.fromCalendarDate 2017 Date.Jan 1
          , menubar = navbarState
          , queryField = ""
          }
        , navbarCmd
        )
