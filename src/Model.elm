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
    { state = Ready { activity = day1 }
    , zone = Time.utc
    }


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
    { activity : Zipper ( Float, Activity ) -- time that each part will be finished by
    , wayPoints : List WayPoint
    , begin : Posix
    , elapsed : Float
    }


mkActiveModel : List ( Float, Activity ) -> Posix -> ActiveModel
mkActiveModel list begin =
    let
        go : ( Float, Activity ) -> ( Float, List ( Float, Activity ) ) -> ( Float, List ( Float, Activity ) )
        go ( len, activity ) ( total, acc ) =
            ( len + total, ( len + total, activity ) :: acc )

        mbActivity =
            list
                |> L.foldl go ( 0, [] )
                |> Tuple.second
                |> L.reverse
                |> Zipper.fromList
    in
    case mbActivity of
        Just activity ->
            { activity = activity
            , wayPoints = []
            , begin = begin
            , elapsed = 0
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
    L.repeat 5 ( min, Running )
        |> L.intersperse ( min, Walking )
        |> (::) ( min, Walking )
        |> flip (++) [ ( min, Walking ) ]


min =
    10 * 1000
