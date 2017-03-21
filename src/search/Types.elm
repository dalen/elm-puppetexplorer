module Search.Types exposing (..)


type alias Model =
    { query : String }


type Msg
    = UpdateQuery String
