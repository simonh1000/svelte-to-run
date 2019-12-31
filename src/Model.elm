module Model exposing (..)

import Basics.Extra exposing (flip)
import List as L
import List.Zipper as Zipper exposing (Zipper)
import Time exposing (Posix)


type alias Model =
    { state : State
    , zone : Time.Zone
    }


blankModel : Model
blankModel =
    { state = Ready { activity = day1 }, zone = Time.utc }


type State
    = Ready ReadyModel
    | Active ActiveModel
    | Finished FinishedModel



--


type alias ReadyModel =
    { activity : List ( Float, Activity ) }



--
{-
   Needs ability to:

       - pause
-}


type alias ActiveModel =
    { activity : Zipper ( Posix, Activity ) -- time that each part will be finished by
    , wayPoints : List WayPoint
    , begin : Posix
    , current : Posix
    }


mkActiveModel : List ( Float, Activity ) -> Posix -> ActiveModel
mkActiveModel list posix =
    let
        mbActivity =
            list
                |> L.map (Tuple.mapFirst (\mins -> mins * 60 * 1000 |> round |> Time.millisToPosix))
                |> Zipper.fromList
    in
    case mbActivity of
        Just activity ->
            { activity = activity
            , wayPoints = []
            , begin = posix
            , current = posix
            }

        Nothing ->
            Debug.todo "mkActiveModel"



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


type Activity
    = Running
    | Walking


day1 =
    L.repeat 5 ( 1, Running )
        |> L.intersperse ( 1, Walking )
        |> (::) ( 5, Walking )
        |> flip (++) [ ( 5, Walking ) ]
