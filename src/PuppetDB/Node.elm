module PuppetDB.Node exposing (..)

import Json.Decode exposing (string, int, list, nullable, at, bool)
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (required, optional)
import Date exposing (Date)
import Status exposing (Status)


type alias Node =
    { certname : String
    , deactivated : Maybe Date
    , expired : Maybe Date
    , catalogTimestamp : Maybe Date
    , factsTimestamp : Maybe Date
    , reportTimestamp : Maybe Date
    , catalogEnvironment : Maybe String
    , factsEnvironment : Maybe String
    , reportEnvironment : Maybe String
    , latestReportStatus : Status
    , latestReportNoop : Maybe Bool
    , latestReportNoopPending : Maybe Bool
    , latestReportHash : Maybe String
    }


listDecoder : Json.Decode.Decoder (List Node)
listDecoder =
    list decoder


decoder : Json.Decode.Decoder Node
decoder =
    Json.Decode.Pipeline.decode Node
        |> required "certname" (string)
        |> optional "deactivated" (nullable date) Nothing
        |> optional "expired" (nullable date) Nothing
        |> optional "catalog_timestamp" (nullable date) Nothing
        |> optional "facts_timestamp" (nullable date) Nothing
        |> optional "report_timestamp" (nullable date) Nothing
        |> optional "catalog_environment" (nullable string) Nothing
        |> optional "facts_environment" (nullable string) Nothing
        |> optional "report_environment" (nullable string) Nothing
        |> optional "latest_report_status" (Status.decoder) Status.Unknown
        |> optional "latest_report_noop" (nullable bool) Nothing
        |> optional "latest_report_noop_pending" (nullable bool) Nothing
        |> optional "latest_report_hash" (nullable string) Nothing
