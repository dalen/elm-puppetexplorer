module PuppetDB.Bean exposing (..)

import Http
import Json.Decode


--get : String -> String -> -> Http.Request a


get : String -> String -> Http.Request Float
get serverUrl bean =
    Http.get
        (serverUrl ++ "/metrics/v1/mbeans/" ++ bean)
        (Json.Decode.at [ "Value" ] Json.Decode.float)
