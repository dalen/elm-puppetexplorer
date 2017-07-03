module Status exposing (..)

import Json.Decode
import Json.Decode.Extra
import Html exposing (Html)
import Material.Icon as Icon
import Material.Color as Color


{-| Handle status field in PuppetDB
-}
type Status
    = Changed
    | Failed
    | Unchanged
    | Unknown


icon : Status -> Html msg
icon status =
    case status of
        Changed ->
            Icon.view "check_circle" [ Color.text (Color.color Color.Green Color.S500) ]

        Unchanged ->
            Icon.view "done" []

        Failed ->
            Icon.view "error" [ Color.text (Color.color Color.DeepOrange Color.A700) ]

        Unknown ->
            Icon.view "help" [ Color.text (Color.color Color.Grey Color.S500) ]


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
