module Model exposing (..)

import Json.Decode as Decode exposing (Decoder)
import List as L
import List.Zipper as Zipper exposing (Zipper)
import Time exposing (Posix)


minute =
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
    ChooseSchema blankChoosing


mapChoosing : (ChoosingModel -> ChoosingModel) -> State -> State
mapChoosing fn state =
    case state of
        ChooseSchema m ->
            ChooseSchema <| fn m

        _ ->
            state



--


type Activity
    = Running
    | Walking


ppActivity : Activity -> String
ppActivity activity =
    case activity of
        Running ->
            "Run"

        Walking ->
            "Walk"



-- ChoosingModel


type alias ChoosingModel =
    { selectedIndex : Maybe Int -- unused
    , add5MinWarmUp : Bool
    }


blankChoosing =
    { selectedIndex = Nothing
    , add5MinWarmUp = True
    }



--


type alias ReadyModel =
    { activity : List SchemaElement
    , position : Maybe WayPoint
    }


mkReadyModel : ChoosingModel -> List SchemaElement -> ReadyModel
mkReadyModel m schema =
    let
        schema_ =
            if m.add5MinWarmUp then
                SchemaElement 5 0 Walking :: schema

            else
                schema
    in
    { activity = calcCumulatives schema_
    , position = Nothing
    }


mkSchema : List ( Float, Activity ) -> List SchemaElement
mkSchema lst =
    let
        go : ( Float, Activity ) -> List SchemaElement -> List SchemaElement
        go ( ct, act ) acc =
            SchemaElement ct 0 act :: acc
    in
    lst
        |> L.foldl go []
        |> L.reverse


calcCumulatives : List SchemaElement -> List SchemaElement
calcCumulatives lst =
    let
        go : SchemaElement -> ( Float, List SchemaElement ) -> ( Float, List SchemaElement )
        go elem ( cum, acc ) =
            let
                cum_ =
                    cum + elem.time * minute
            in
            ( cum_
            , { elem | cumulative = cum_ } :: acc
            )
    in
    lst
        |> L.foldl go ( 0, [] )
        |> (\( _, tmp ) -> L.reverse tmp)



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


mkFinishedModel : ActiveModel -> FinishedModel
mkFinishedModel m =
    { wayPoints = m.wayPoints
    , begin = m.begin
    , end = m.begin
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


type alias DayRun =
    { title : String
    , schema : List ( Float, Activity )
    }


startToRun : List DayRun
startToRun =
    [ DayRun "short" [ r 1, w 1, r 1, w 1, r 2, w 2, r 1, w 1, r 1, w 1, r 1 ]
    , DayRun "day 1" [ r 1, w 1, r 1, w 1, r 2, w 2, r 2, w 2, r 3 ]
    , DayRun "day 2" [ r 1, w 1, r 1, w 1, r 2, w 2, r 3, w 3, r 3 ]
    , DayRun "day 3" [ r 1, w 1, r 2, w 2, r 2, w 2, r 3, w 3, r 3 ]
    ]


w int =
    ( int, Walking )


r int =
    ( int, Running )
