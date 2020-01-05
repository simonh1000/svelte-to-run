port module Ports exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Model exposing (WayPoint, decodeWayPoint)


port toJs : PortMsg -> Cmd msg


port fromJs : (PortMsg -> msg) -> Sub msg


type alias PortMsg =
    { tag : String
    , payload : Value
    }


type PortOutgoing
    = Announce String
    | ToReady


sendToPort : PortOutgoing -> Cmd msg
sendToPort =
    mkPortMsg >> toJs


mkPortMsg : PortOutgoing -> PortMsg
mkPortMsg tp =
    case tp of
        Announce msg ->
            PortMsg "announce" <| Encode.string msg

        ToReady ->
            PortMsg "ready" Encode.null


type PortIncoming
    = NextWayPoint WayPoint
    | Error String


decodePortIncoming : PortMsg -> PortIncoming
decodePortIncoming { tag, payload } =
    let
        apply dec =
            case Decode.decodeValue dec payload of
                Ok msg ->
                    msg

                Err err ->
                    Error <| Decode.errorToString err
    in
    case tag of
        "waypoint" ->
            apply decNextWayPoint

        _ ->
            Error ("No decoder for " ++ tag)


decNextWayPoint : Decoder PortIncoming
decNextWayPoint =
    Decode.map NextWayPoint decodeWayPoint
