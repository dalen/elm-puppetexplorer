module Data.Common exposing (Common, init)

import Date
import Date.Extra
import Config exposing (Config)


type alias Common =
    { config : Config
    , queryField : String
    , date : Date.Date
    }


init : Config -> Common
init config navbarMsg =
    { config = config
    , menubar = navbarState
    , queryField = ""
    , date = Date.Extra.fromCalendarDate 2017 Date.Jan 1
    }
