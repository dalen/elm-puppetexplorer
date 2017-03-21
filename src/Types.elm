module Types exposing (..)

import Menubar.Types


type alias Model =
    { string : String
    , menubar : Menubar.Types.Model
    }


type Msg
    = MenubarMsg Menubar.Types.Msg
    | NoOp
