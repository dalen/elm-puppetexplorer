module PuppetDB exposing (pql, subquery, request)

import Http
import Json.Decode
import Erl


maybeAddQuery : String -> Maybe String -> Erl.Url -> Erl.Url
maybeAddQuery key value url =
    case value of
        Just value ->
            Erl.addQuery key value url

        Nothing ->
            url


{-| New replacement query function that returns a request
-}
request : String -> String -> Json.Decode.Decoder a -> Http.Request a
request serverUrl pql decoder =
    let
        url =
            Erl.toString
                (Erl.parse serverUrl
                    |> Erl.appendPathSegments [ "pdb", "query", "v4" ]
                    |> Erl.addQuery "query" pql
                )
    in
        Http.get url decoder


{-| Create a PQL subquery
-}
subquery : String -> Maybe String -> String
subquery endpoint inner =
    case inner of
        Just s ->
            if String.isEmpty (String.trim s) then
                ""
            else
                endpoint ++ "{" ++ s ++ "}"

        Nothing ->
            ""


{-| Create a regular PQL statement
-}
pql : String -> List String -> String -> String
pql endpoint extract inner =
    if List.isEmpty extract then
        endpoint ++ "{" ++ inner ++ "}"
    else
        endpoint ++ "[" ++ String.join "," extract ++ "]{" ++ inner ++ "}"
