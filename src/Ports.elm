port module Ports exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Model exposing (..)


port toJs : PortMsg -> Cmd msg


port fromJs : (PortMsg -> msg) -> Sub msg


type alias PortMsg =
    { tag : String
    , payload : Value
    }


type PortOutgoing
    = Announce { txt : String, mins : Int, activity : Activity }
    | Speak String
    | ToReady


sendToPort : PortOutgoing -> Cmd msg
sendToPort =
    mkPortMsg >> toJs


mkPortMsg : PortOutgoing -> PortMsg
mkPortMsg tp =
    case tp of
        Announce msg ->
            [ ( "txt", Encode.string msg.txt )
            , ( "mins", Encode.int msg.mins )
            , ( "activity", Encode.string <| ppActivity msg.activity )
            ]
                |> Encode.object
                |> PortMsg "announce"

        ToReady ->
            PortMsg "ready" Encode.null

        Speak string ->
            PortMsg "speak" <| Encode.string string


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

        "error" ->
            Decode.value
                |> Decode.map (Encode.encode 0 >> Error)
                |> apply

        _ ->
            Error ("No decoder for " ++ tag)


decNextWayPoint : Decoder PortIncoming
decNextWayPoint =
    Decode.map NextWayPoint decodeWayPoint
