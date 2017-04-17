module PuppetDB exposing (fetchBean)

import Http
import Json.Decode


fetchBean : String -> String -> (Result Http.Error Float -> msg) -> Cmd msg
fetchBean serverUrl bean msg =
    let
        url =
            serverUrl ++ "/metrics/v1/mbeans/" ++ bean
    in
        Http.send msg (Http.get url (Json.Decode.at [ "Value" ] Json.Decode.float))
