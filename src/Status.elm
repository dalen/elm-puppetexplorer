module Status exposing (..)

import Json.Decode
import Json.Decode.Extra
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
            Html.node "iron-icon" [ attribute "icon" "check-circle", Html.Attributes.class "status-changed" ] []

        Unchanged ->
            Html.node "iron-icon" [ attribute "icon" "done", Html.Attributes.class "status-unchanged" ] []

        Failed ->
            Html.node "iron-icon" [ attribute "icon" "error", Html.Attributes.class "status-failed" ] []

        Unknown ->
            Html.node "iron-icon" [ attribute "icon" "help", Html.Attributes.class "status-unknown" ] []


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
