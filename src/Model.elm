module Model exposing (..)

import Json.Decode as Decode exposing (Decoder)
import List as L
import List.Zipper as Zipper exposing (Zipper)
import Time exposing (Posix)


min =
    60 * 1000


type alias Model =
    { state : State
    , zone : Time.Zone
    }


blankModel : Model
blankModel =
    { state = initState
    , zone = Time.utc
    }


type State
    = ChooseSchema ChoosingModel
    | Ready ReadyModel
    | Active ActiveModel
    | Finished FinishedModel


initState : State
initState =
    ChooseSchema { selectedIndex = Nothing }


type Activity
    = Running
    | Walking



-- ChoosingModel


type alias ChoosingModel =
    { selectedIndex : Maybe Int -- unused
    }



--


type alias ReadyModel =
    { activity : List SchemaElement
    , position : Maybe WayPoint
    }


mkReadyModel : List SchemaElement -> ReadyModel
mkReadyModel schema =
    { activity = schema
    , position = Nothing
    }


mkSchema : List Float -> List SchemaElement
mkSchema lst =
    let
        go : Float -> ( Activity, Float, List SchemaElement ) -> ( Activity, Float, List SchemaElement )
        go ct ( nxt, cum, acc ) =
            let
                ct_ =
                    ct * min
            in
            ( if nxt == Running then
                Walking

              else
                Running
            , cum + ct_
            , SchemaElement ct (cum + ct_) nxt :: acc
            )
    in
    lst
        |> L.foldl go ( Walking, 0, [] )
        |> (\( _, _, tmp ) -> L.reverse tmp)



{- ActiveModel

   Needs ability to:

       - pause
-}


type alias ActiveModel =
    { activity : Zipper SchemaElement -- time that each part will be finished by
    , wayPoints : List WayPoint
    , begin : Posix
    , elapsed : Float
    }


type alias SchemaElement =
    { time : Float
    , cumulative : Float
    , activity : Activity
    }


mkActiveModel : ReadyModel -> Posix -> ActiveModel
mkActiveModel m begin =
    case Zipper.fromList m.activity of
        Just activity ->
            { activity = activity
            , wayPoints = m.position |> Maybe.map L.singleton |> Maybe.withDefault []
            , begin = begin
            , elapsed = 0
            }

        Nothing ->
            Debug.todo "no schema"



--


type alias FinishedModel =
    { wayPoints : List WayPoint
    , begin : Posix
    , end : Posix
    }



--


type alias WayPoint =
    { lat : Float
    , lng : Float
    , time : Posix
    }


decodeWayPoint : Decoder WayPoint
decodeWayPoint =
    Decode.map3 WayPoint
        (Decode.at [ "coords", "latitude" ] Decode.float)
        (Decode.at [ "coords", "longitude" ] Decode.float)
        (Decode.field "timestamp" <| Decode.map Time.millisToPosix Decode.int)



-- data


startToRun =
    [ [ 5, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1 ]
    , [ 1, 1, 1, 1, 2, 2, 2, 2, 3 ]
    , [ 1, 1, 1, 1, 2, 2, 3, 3, 3, 3 ]
    , [ 1, 1, 2, 2, 2, 2, 3, 3, 3, 3 ]
    ]
