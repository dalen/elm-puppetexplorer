module Main exposing (..)

import Navigation exposing (Location)
import Types exposing (..)
import State
import View


main : Program Never Types.Model Types.Msg
main =
    Navigation.program LocationChangeMsg
        { init = State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view
        }
