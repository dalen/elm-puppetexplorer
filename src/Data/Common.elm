module Data.Common exposing (Common, init)

import Date
import Date.Extra
import Config exposing (Config)
import Bootstrap.Navbar as Navbar


type alias Common =
    { config : Config
    , menubar : Navbar.State
    , queryField : String
    , date : Date.Date
    }


init : Config -> (Navbar.State -> msg) -> ( Common, Cmd msg )
init config navbarMsg =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState navbarMsg
    in
        ( { config = config
          , menubar = navbarState
          , queryField = ""
          , date = Date.Extra.fromCalendarDate 2017 Date.Jan 1
          }
        , navbarCmd
        )
