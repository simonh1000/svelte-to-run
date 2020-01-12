module Model exposing (..)

import Common.CoreHelpers exposing (ifThenElse)
import Json.Decode as Decode exposing (Decoder)
import List as L
import List.Zipper as Zipper exposing (Zipper)
import Time exposing (Posix)


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
    ChooseSchema <| mkChoosingModel []


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
    , devMode : Bool
    , runs : List DayRun
    }


type alias DayRun =
    { title : String
    , schema : List ( Float, Activity )
    }


mkChoosingModel : Flags -> ChoosingModel
mkChoosingModel flags =
    { selectedIndex = Nothing
    , add5MinWarmUp = True
    , devMode = False
    , runs = convertFlags flags
    }



--


type alias ReadyModel =
    { activity : List SchemaElement
    , position : Maybe WayPoint
    }


mkReadyModel : ChoosingModel -> List SchemaElement -> ReadyModel
mkReadyModel m schema =
    let
        minute =
            ifThenElse m.devMode 10 60

        schema_ =
            if m.add5MinWarmUp then
                SchemaElement 5 0 Walking :: schema

            else
                schema
    in
    { activity = calcCumulatives minute schema_
    , position = Nothing
    }


dayRunToSchema : List ( Float, Activity ) -> List SchemaElement
dayRunToSchema lst =
    let
        go : ( Float, Activity ) -> List SchemaElement -> List SchemaElement
        go ( ct, act ) acc =
            SchemaElement ct 0 act :: acc
    in
    lst
        |> L.foldl go []
        |> L.reverse


calcCumulatives : Float -> List SchemaElement -> List SchemaElement
calcCumulatives minute lst =
    let
        go : SchemaElement -> ( Float, List SchemaElement ) -> ( Float, List SchemaElement )
        go elem ( cum, acc ) =
            let
                cum_ =
                    cum + elem.time * minute * 1000
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


type alias Flags =
    List ( String, List String )


convertFlags : Flags -> List DayRun
convertFlags =
    L.map (\( title, lst ) -> DayRun title <| L.map convert lst)


convert : String -> ( Float, Activity )
convert s =
    let
        activity =
            if String.left 1 s == "r" then
                Running

            else
                Walking

        time =
            String.dropLeft 1 s
                |> String.toFloat
                |> Maybe.withDefault 0
    in
    ( time, activity )
