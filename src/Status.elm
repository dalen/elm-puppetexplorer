module Status exposing (..)

import Json.Decode
import Json.Decode.Extra
import Material.List as Lists
import Material.Color as Color
import Html exposing (Html)


{-| Handle status field in PuppetDB
-}
type Status
    = Changed
    | Failed
    | Unchanged
    | Unknown


listIcon : Status -> Html msg
listIcon status =
    case status of
        Changed ->
            Lists.icon "check_circle" [ Color.text (Color.color Color.Green Color.S500) ]

        Unchanged ->
            Lists.icon "done" []

        Failed ->
            Lists.icon "error" [ Color.text (Color.color Color.Red Color.S500) ]

        Unknown ->
            Lists.icon "help" []


decoder : Json.Decode.Decoder Status
decoder =
    Json.Decode.oneOf
        [ Json.Decode.string
            |> Json.Decode.andThen
                (Json.Decode.Extra.fromResult
                    << (\val ->
                            case val of
                                "changed" ->
                                    Ok Changed

                                "unchanged" ->
                                    Ok Unchanged

                                "failed" ->
                                    Ok Failed

                                _ ->
                                    Err "Unknown value"
                       )
                )
        , Json.Decode.null Unknown
        ]
