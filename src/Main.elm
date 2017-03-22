module Main exposing (..)

import Navigation exposing (Location)
import State
import Types
import View


parseRoute : Location -> Types.Msg
parseRoute location =
    Types.LocationChange location


main : Program Never Types.Model Types.Msg
main =
    Navigation.program parseRoute
        { init = State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view
        }
