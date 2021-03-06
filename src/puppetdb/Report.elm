module PuppetDB.Report exposing (..)

import Json.Decode exposing (string, int, list, nullable, at)
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline
import Date exposing (Date)
import Status exposing (Status)
import List.Extra


type EventStatus
    = Success
    | Failure
    | Noop
    | Skipped


type alias Report =
    { receiveTime : Date
    , hash : String
    , transactionUuid : String
    , puppetVersion : String
    , noop : Bool
    , noopPending : Maybe Bool
    , reportFormat : Int
    , startTime : Date
    , endTime : Date
    , producerTimestamp : Date
    , producer : Maybe String
    , resourceEvents : Maybe (List Event)
    , status : Status
    , configurationVersion : String
    , environment : String
    , certname : String
    , metrics : List Metric
    , logs : List Log
    }


type alias Event =
    { newValue : Json.Decode.Value
    , property : Maybe String
    , file : Maybe String
    , oldValue : Json.Decode.Value
    , line : Maybe Int
    , resourceType : String
    , status : EventStatus
    , resourceTitle : String
    , timestamp : Date
    , containmentPath : Maybe (List String)
    , message : Maybe String
    }


type alias Log =
    { file : Maybe String
    , line : Maybe Int
    , level : String
    , message : String
    , source : String
    , tags : List String
    , time : Date
    }


type alias Metric =
    { category : String
    , name : String
    , value : Float
    }


listDecoder : Json.Decode.Decoder (List Report)
listDecoder =
    list decoder


decoder : Json.Decode.Decoder Report
decoder =
    Json.Decode.Pipeline.decode Report
        |> Json.Decode.Pipeline.required "receive_time" (date)
        |> Json.Decode.Pipeline.required "hash" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "transaction_uuid" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "puppet_version" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "noop" (Json.Decode.bool)
        |> Json.Decode.Pipeline.required "noop_pending" (nullable Json.Decode.bool)
        |> Json.Decode.Pipeline.required "report_format" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "start_time" date
        |> Json.Decode.Pipeline.required "end_time" (date)
        |> Json.Decode.Pipeline.required "producer_timestamp" (date)
        |> Json.Decode.Pipeline.required "producer" (nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "resource_events" (Json.Decode.at [ "data" ] (nullable (list decodeEvent)))
        |> Json.Decode.Pipeline.required "status" (Status.decoder)
        |> Json.Decode.Pipeline.required "configuration_version" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "environment" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "certname" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "metrics" (Json.Decode.at [ "data" ] (list decodeMetric))
        |> Json.Decode.Pipeline.required "logs" (Json.Decode.at [ "data" ] (list decodeLog))


decodeEvent : Json.Decode.Decoder Event
decodeEvent =
    Json.Decode.Pipeline.decode Event
        |> Json.Decode.Pipeline.required "new_value" (Json.Decode.value)
        |> Json.Decode.Pipeline.required "property" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "file" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "old_value" (Json.Decode.value)
        |> Json.Decode.Pipeline.required "line" (Json.Decode.nullable Json.Decode.int)
        |> Json.Decode.Pipeline.required "resource_type" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "status" (decodeEventStatus)
        |> Json.Decode.Pipeline.required "resource_title" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "timestamp" (date)
        |> Json.Decode.Pipeline.required "containment_path" (Json.Decode.nullable (Json.Decode.list Json.Decode.string))
        |> Json.Decode.Pipeline.required "message" (Json.Decode.nullable Json.Decode.string)


decodeLog : Json.Decode.Decoder Log
decodeLog =
    Json.Decode.Pipeline.decode Log
        |> Json.Decode.Pipeline.required "file" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "line" (Json.Decode.nullable Json.Decode.int)
        |> Json.Decode.Pipeline.required "level" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "message" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "source" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "tags" (Json.Decode.list Json.Decode.string)
        |> Json.Decode.Pipeline.required "time" (date)


decodeMetric : Json.Decode.Decoder Metric
decodeMetric =
    Json.Decode.Pipeline.decode Metric
        |> Json.Decode.Pipeline.required "category" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "name" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "value" (Json.Decode.float)


decodeEventStatus : Json.Decode.Decoder EventStatus
decodeEventStatus =
    Json.Decode.string
        |> Json.Decode.andThen
            (Json.Decode.Extra.fromResult
                << (\val ->
                        case val of
                            "success" ->
                                Ok Success

                            "failure" ->
                                Ok Failure

                            "noop" ->
                                Ok Noop

                            "skipped" ->
                                Ok Skipped

                            _ ->
                                Err "Unknown value"
                   )
            )


getMetric : String -> String -> Report -> Maybe Float
getMetric category name report =
    List.Extra.find (\metric -> metric.category == category && metric.name == name) report.metrics
        |> Maybe.map (\metric -> metric.value)
