module Status exposing (..)

import Json.Decode
import Json.Decode.Extra
import Material.List as Lists
import Material.Color as Color
import Html exposing (Html)
import Html.Attributes exposing (attribute)


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
            -- TODO: green
            Html.node "iron-icon" [ attribute "icon" "check-circle" ] []

        Unchanged ->
            Html.node "iron-icon" [ attribute "icon" "done" ] []

        Failed ->
            -- TODO: red
            Html.node "iron-icon" [ attribute "icon" "error" ] []

        Unknown ->
            Html.node "iron-icon" [ attribute "icon" "help" ] []


listIcon =
    icon


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
