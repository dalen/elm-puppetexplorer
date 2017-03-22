module Types exposing (..)

import Menubar.Types
import Navigation exposing (Location)
import Search.Types


type alias Model =
    { string : String
    , menubar : Menubar.Types.Model
    , search : Search.Types.Model
    , route : Maybe Route
    }


type Route
    = Dashboard (Maybe String)
    | NodeList (Maybe String)


type Msg
    = MenubarMsg Menubar.Types.Msg
    | SearchMsg Search.Types.Msg
    | LocationChange Location
    | NoOp
