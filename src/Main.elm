module Main exposing (..)

import Navigation exposing (Location)
import Types
import State
import View


main : Program Types.Config Types.Model Types.Msg
main =
    Navigation.programWithFlags Types.LocationChangeMsg
        { init = State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view
        }
