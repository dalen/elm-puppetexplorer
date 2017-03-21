module Types exposing (..)

import Menubar.Types
import Search.Types


type alias Model =
    { string : String
    , menubar : Menubar.Types.Model
    , search : Search.Types.Model
    }


type Msg
    = MenubarMsg Menubar.Types.Msg
    | SearchMsg Search.Types.Msg
    | NoOp
