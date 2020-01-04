module Main exposing (..)

import Browser
import Common.CoreHelpers exposing (formatPluralRegular, ifThenElse)
import DateFormat as DF
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List as L
import List.Zipper as Zipper exposing (Zipper)
import Model exposing (..)
import Ports exposing (PortIncoming(..), PortOutgoing(..), decodePortIncoming)
import Task
import Time exposing (Posix, Zone)


init : Int -> ( Model, Cmd Msg )
init flags =
    ( blankModel, Time.here |> Task.perform OnTimeZone )



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = SelectSchema (List Float)
      -- Ready
    | Start
    | OnStartTime Posix
      -- Active
    | Pause
    | Stop
    | OnEachSecond Posix
    | OnPortIncoming PortIncoming
    | OnTimeZone Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        SelectSchema lst ->
            --( { model | state = Ready <| mkReadyModel (5 :: lst ++ [ 5 ]) }, Cmd.none )
            ( { model | state = Ready <| mkReadyModel lst }
            , Ports.sendToPort Ports.LoadSoundPlayer
            )

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
                                , Cmd.none
                                )

                    else
                        ( { model | state = Active state_ }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Stop ->
            ( { model | state = initState }, Cmd.none )

        OnTimeZone zone ->
            ( { model | zone = zone }, Cmd.none )

        OnPortIncoming portMsg ->
            case ( portMsg, model.state ) of
                ( Error s, _ ) ->
                    let
                        _ =
                            Debug.log "port error" s
                    in
                    ( model, Cmd.none )

                ( NextWayPoint p, Ready state ) ->
                    ( { model | state = Ready { state | position = Just p } }, Cmd.none )

                ( NextWayPoint p, Active state ) ->
                    ( { model | state = Active { state | wayPoints = p :: state.wayPoints } }, Cmd.none )

                _ ->
                    Debug.todo "Port error"

        _ ->
            ( model, Cmd.none )



-- Update Helpers


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
    Zipper.current activity
        |> mkFullText
        |> Announce
        |> Ports.sendToPort



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view model =
    div [ class "content" ] <|
        case model.state of
            ChooseSchema m ->
                viewChoosing m

            Ready m ->
                viewReady m

            Active m ->
                viewActive model.zone m

            Finished finishedModel ->
                [ text "TBC" ]


viewChoosing : ChoosingModel -> List (Html Msg)
viewChoosing { selectedIndex } =
    let
        mkItem idx schema =
            li
                [ class <| ifThenElse (Just idx == selectedIndex) "pure-menu-item selected" "pure-menu-item"
                , onClick <| SelectSchema schema
                ]
                [ text <| Debug.toString schema ]

        days =
            startToRun
                |> L.indexedMap mkItem
                |> ul [ class "pure-menu-list" ]
    in
    [ h1 [] [ text "Choose schema" ]
    , div [ class "pure-menu custom-restricted-width" ] [ days ]
    ]


viewReady : ReadyModel -> List (Html Msg)
viewReady m =
    [ h1 [] [ text "Ready" ]
    , m.activity
        |> L.map (viewActivity "")
        |> ul []
    , div [] [ mkButton Start "Start" ]
    , div [] [ text <| Debug.toString m.position ]
    ]


viewActive : Zone -> ActiveModel -> List (Html Msg)
viewActive zone m =
    let
        before =
            Zipper.before m.activity |> L.map (viewActivity "before")

        current =
            Zipper.current m.activity |> viewActivity "current"

        after =
            Zipper.after m.activity |> L.map (viewActivity "after")
    in
    [ h1 [] [ text "Active" ]
    , before ++ current :: after |> ul []
    , div [] [ text <| DF.format [ DF.minuteFixed, DF.text ":", DF.secondFixed ] zone m.begin ]
    , div [] [ text <| String.fromFloat m.elapsed ]
    , div [] [ mkButton Stop "Stop" ]
    ]



-- View Helpers


viewActivity : String -> SchemaElement -> Html msg
viewActivity cls item =
    li [ class cls ] [ text <| String.fromFloat item.time ++ " mins " ++ Debug.toString item.activity ]


mkButton : msg -> String -> Html msg
mkButton msg txt =
    button
        [ id "start-button"
        , class "pure-button"
        , onClick msg
        ]
        [ text txt ]



-- ---------------------------
-- Subscriptions
-- ---------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ stateSubs model
        , Ports.fromJs (decodePortIncoming >> OnPortIncoming)
        ]


stateSubs model =
    case model.state of
        Active _ ->
            Time.every 1000 OnEachSecond

        _ ->
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
