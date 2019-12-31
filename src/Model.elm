module Model exposing (..)

import Basics.Extra exposing (flip)
import List as L
import List.Zipper as Zipper exposing (Zipper)
import Time exposing (Posix)


type alias Model =
    { state : State }


blankModel : Model
blankModel =
    { state = Ready { activity = day1 } }


type State
    = Ready ReadyModel
    | Active ActiveModel
    | Finished FinishedModel



--


type alias ReadyModel =
    { activity : List ( Float, Activity ) }



--


type alias ActiveModel =
    { activity : Zipper ( Float, Activity )
    , wayPoints : List WayPoint
    , begin : Posix
    , current : Posix
    }


mkActiveModel : List ( Float, Activity ) -> Posix -> ActiveModel
mkActiveModel list posix =
    { activity = Zipper.fromList list |> Maybe.withDefault (Zipper.singleton ( 1, Walking ))
    , wayPoints = []
    , begin = posix
    , current = posix
    }



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
