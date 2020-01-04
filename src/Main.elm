port module Main exposing (..)

import Browser
import Common.CoreHelpers exposing (formatPluralRegular, ifThenElse)
import DateFormat as DF
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Encode as Encode exposing (Value)
import List as L
import List.Zipper as Zipper exposing (Zipper)
import Model exposing (..)
import Task
import Time exposing (Posix, Zone)


init : Int -> ( Model, Cmd Msg )
init flags =
    ( blankModel, Time.here |> Task.perform OnTimeZone )


port toJs : Value -> Cmd msg



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = SelectSchema (List Float)
      -- Ready
    | Start
    | OnStartTime Posix
      -- Running
    | Pause
    | OnEachSecond Posix
    | Stop
    | OnTimeZone Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    let
        cmd =
            toJs Encode.null
    in
    case message of
        SelectSchema lst ->
            --( { model | state = Ready <| mkReadyModel (5 :: lst ++ [ 5 ]) }, Cmd.none )
            ( { model | state = Ready <| mkReadyModel lst }, Cmd.none )

        Start ->
            ( model, Time.now |> Task.perform OnStartTime )

        OnStartTime now ->
            case model.state of
                Ready { activity } ->
                    let
                        m =
                            mkActiveModel activity now
                    in
                    ( { model | state = Active m }
                    , announce m.activity
                    )

                _ ->
                    ( model, Cmd.none )

        OnEachSecond now ->
            case model.state of
                Active state ->
                    let
                        elapsed =
                            toFloat (Time.posixToMillis now - Time.posixToMillis state.begin)

                        state_ =
                            { state | elapsed = elapsed }
                    in
                    if elapsed > .cumulative (Zipper.current state.activity) then
                        case Zipper.next state.activity of
                            Just activity ->
                                ( { model | state = Active { state_ | activity = activity } }
                                , announce activity
                                )

                            Nothing ->
                                let
                                    state2 =
                                        { wayPoints = []
                                        , begin = state.begin
                                        , end = now
                                        }
                                in
                                ( { model | state = Finished state2 }
                                , toJs Encode.null
                                )

                    else
                        ( { model | state = Active state_ }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Stop ->
            ( { model | state = initState }, Cmd.none )

        OnTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        _ ->
            ( model, Cmd.none )


announce : Zipper SchemaElement -> Cmd msg
announce activity =
    let
        convert elem =
            case elem.activity of
                Running ->
                    "run"

                Walking ->
                    "walk"

        mkFullText elem =
            "Now " ++ convert elem ++ " for " ++ formatPluralRegular (round elem.time) "minute"
    in
    toJs <| Encode.string <| mkFullText <| Zipper.current activity



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view model =
    case model.state of
        ChooseSchema m ->
            viewChoosing m

        Ready { activity } ->
            div [ class "container" ]
                [ h1 [] [ text "Ready" ]
                , activity
                    |> L.map (viewActivity "")
                    |> ul []
                , button [ onClick Start, id "start-button" ] [ text "Start" ]
                ]

        Active state ->
            let
                before =
                    Zipper.before state.activity |> L.map (viewActivity "before")

                current =
                    Zipper.current state.activity |> viewActivity "current"

                after =
                    Zipper.after state.activity |> L.map (viewActivity "after")
            in
            div [ class "container" ]
                [ h1 [] [ text "Active" ]
                , before ++ current :: after |> ul []
                , div [] [ text <| DF.format [ DF.minuteFixed, DF.text ":", DF.secondFixed ] model.zone state.begin ]
                , div [] [ text <| String.fromFloat state.elapsed ]
                , div [] [ button [ onClick Stop, id "start-button" ] [ text "Stop" ] ]
                ]

        Finished finishedModel ->
            text "TBC"


viewChoosing : ChoosingModel -> Html Msg
viewChoosing { selectedIndex } =
    let
        mkItem idx schema =
            li
                [ class <| ifThenElse (Just idx == selectedIndex) "selected" ""
                , onClick <| SelectSchema schema
                ]
                [ text <| Debug.toString schema ]
    in
    startToRun
        |> L.indexedMap mkItem
        |> ul []


viewActivity : String -> SchemaElement -> Html msg
viewActivity cls item =
    li [ class cls ] [ text <| String.fromFloat item.time ++ " mins " ++ Debug.toString item.activity ]



-- ---------------------------
-- Subscriptions
-- ---------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.state of
        ChooseSchema choosingModel ->
            Sub.none

        Ready _ ->
            Sub.none

        Active activeModel ->
            Time.every 1000 OnEachSecond

        Finished finishedModel ->
            Sub.none



-- ---------------------------
-- MAIN
-- ---------------------------


main : Program Int Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Start to Run"
                , body = [ view m ]
                }
        , subscriptions = subscriptions
        }
