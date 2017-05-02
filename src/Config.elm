module Config exposing (..)

import Types exposing (..)
import Http
import Json.Decode exposing (int, float, string, list, nullable, map)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Bootstrap.Card
import RemoteData


fetch : Cmd Msg
fetch =
    let
        url =
            "/config.json"
    in
        Http.get url decoder
            |> RemoteData.sendRequest
            |> Cmd.map UpdateConfigMsg


styleDecoder : String -> Bootstrap.Card.CardOption msg
styleDecoder value =
    case value of
        "primary" ->
            Bootstrap.Card.primary

        _ ->
            Bootstrap.Card.primary


decoder : Json.Decode.Decoder Config
decoder =
    Json.Decode.Pipeline.decode Config
        |> required "serverUrl" string
        |> required "nodeFacts" (list string)
        |> required "unresponsiveHours" int
        |> required "dashboardPanels"
            (list
                (list
                    (Json.Decode.Pipeline.decode
                        DashboardPanelConfig
                        |> required "title" string
                        |> required "bean" string
                        |> required "style" (map styleDecoder string)
                        |> optional "multiply" (map Just float) Nothing
                        |> optional "unit" (map Just string) Nothing
                        |> optional "value" (map Just float) Nothing
                    )
                )
            )
