module Types exposing (..)

import Menubar.Types
import Search.Types
import Navigation exposing (Location)


type alias Model =
    { string : String
    , menubar : Menubar.Types.Model
    , search : Search.Types.Model
    }


type Msg
    = MenubarMsg Menubar.Types.Msg
    | SearchMsg Search.Types.Msg
    | LocationChange Location
    | NoOp
