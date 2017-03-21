module Main exposing (..)

import Html exposing (program)
import Types
import State
import View


main : Program Never Types.Model Types.Msg
main =
    program
        { init = State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view
        }
