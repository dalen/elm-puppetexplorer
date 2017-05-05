module PuppetDB exposing (fetch, fetchBean, queryPQL, pql, pqlInventory)

import Http
import Json.Decode
import Erl
import RemoteData exposing (WebData)


fetchBean : String -> String -> (RemoteData.WebData Float -> msg) -> Cmd msg
fetchBean serverUrl bean msg =
    fetch
        serverUrl
        ("/metrics/v1/mbeans/" ++ bean)
        (Json.Decode.at [ "Value" ] Json.Decode.float)
        msg


maybeAddQuery : String -> Maybe String -> Erl.Url -> Erl.Url
maybeAddQuery key value url =
    case value of
        Just value ->
            Erl.addQuery key value url

        Nothing ->
            url


query : String -> String -> Maybe Int -> Maybe Int -> String -> Json.Decode.Decoder a -> (WebData a -> msg) -> Cmd msg
query serverUrl endpoint offset limit pql decoder msg =
    let
        url =
            Erl.toString
                (Erl.parse serverUrl
                    |> Erl.appendPathSegments [ "pdb", "query", "v4" ]
                    |> Erl.addQuery "query" pql
                    |> maybeAddQuery "offset" (Maybe.map toString offset)
                    |> maybeAddQuery "limit" (Maybe.map toString limit)
                )
    in
        Http.get url decoder
            |> RemoteData.sendRequest
            |> Cmd.map msg


queryPQL : String -> String -> Json.Decode.Decoder a -> (WebData a -> msg) -> Cmd msg
queryPQL serverUrl pql decoder msg =
    let
        url =
            Erl.toString
                (Erl.parse serverUrl
                    |> Erl.appendPathSegments [ "pdb", "query", "v4" ]
                    |> Erl.addQuery "query" pql
                )
    in
        Http.get url decoder
            |> RemoteData.sendRequest
            |> Cmd.map msg


{-| Generic function to fetch data from PuppetDB
-}
fetch : String -> String -> Json.Decode.Decoder a -> (WebData a -> msg) -> Cmd msg
fetch serverUrl path decoder msg =
    let
        url =
            serverUrl ++ path
    in
        Http.get url decoder
            |> RemoteData.sendRequest
            |> Cmd.map msg


{-| Create a PQL subquery
-}
subquery : String -> String -> String
subquery endpoint inner =
    endpoint ++ "{" ++ inner ++ "}"


{-| Create a regular PQL statement
-}
pql : String -> List String -> String -> String
pql endpoint extract inner =
    if List.isEmpty extract then
        endpoint ++ "{" ++ inner ++ "}"
    else
        endpoint ++ "[" ++ String.join "," extract ++ "]{" ++ inner ++ "}"


{-| Create a PQL statement with a inventory query
-}
pqlInventory : String -> List String -> String -> Maybe String -> String
pqlInventory endpoint extract inner inventoryQuery =
    let
        innerQuery =
            case inventoryQuery of
                Just inventoryQuery ->
                    (subquery "inventory" inventoryQuery) ++ " and " ++ inner

                Nothing ->
                    inner
    in
        pql endpoint extract innerQuery
