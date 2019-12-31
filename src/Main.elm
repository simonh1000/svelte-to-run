port module Main exposing (..)

import Browser
import DateFormat as DF
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Encode as Encode exposing (Value)
import List as L
import List.Zipper as Zipper
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
    = Start
    | OnStartTime Posix
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
        Start ->
            ( model, Time.now |> Task.perform OnStartTime )

        OnStartTime now ->
            case model.state of
                Ready { activity } ->
                    ( { model | state = Active <| mkActiveModel activity now }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        OnEachSecond now ->
            case model.state of
                Active state ->
                    ( { model | state = Active { state | current = now } }
                    , toJs Encode.null
                      --, Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        OnTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view model =
    case model.state of
        Ready { activity } ->
            div [ class "container" ]
                [ h1 [] [ text "Ready" ]
                , viewActivity activity
                , button [ onClick Start, id "start-button" ] [ text "Start" ]
                ]

        Active state ->
            div [ class "container" ]
                [ h1 [] [ text "Active" ]
                , state.activity |> Zipper.toList |> viewActivity

                --, text <| String.fromInt <| (Time.posixToMillis state.current // 1000)
                , div [] [ text <| DF.format [ DF.minuteFixed, DF.text ":", DF.secondFixed ] model.zone state.begin ]
                , div [] [ text <| DF.format [ DF.secondFixed ] model.zone state.current ]
                , div [] [ button [ onClick Stop, id "start-button" ] [ text "Stop" ] ]
                ]

        Finished finishedModel ->
            text "TBC"


viewActivity activity =
    let
        mkItem ( flt, elem ) =
            div [] [ text <| Debug.toString ( flt, elem ) ]
    in
    activity
        |> L.map mkItem
        |> div []



-- ---------------------------
-- Subscriptions
-- ---------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        eachSecond =
            Time.every 1000 OnEachSecond
    in
    case model.state of
        Ready _ ->
            Sub.none

        Active activeModel ->
            eachSecond

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
