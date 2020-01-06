module Main exposing (..)

import Browser
import Common.CoreHelpers exposing (formatPluralRegular, ifThenElse)
import DateFormat as DF
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick)
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
    = SelectSchema (List SchemaElement)
    | ToggleWarmUp Bool
      -- Ready
    | Start
    | OnStartTime Posix
      -- Active
    | Pause
    | Cancel
    | OnEachSecond Posix
    | OnPortIncoming PortIncoming
    | OnTimeZone Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ToggleWarmUp add5MinWarmUp ->
            ( { model | state = mapChoosing (\m -> { m | add5MinWarmUp = add5MinWarmUp }) model.state }, Cmd.none )

        SelectSchema schema ->
            case model.state of
                ChooseSchema state ->
                    ( { model | state = Ready <| mkReadyModel state schema }
                    , Ports.sendToPort Ports.ToReady
                    )

                _ ->
                    ( model, Cmd.none )

        Start ->
            ( model, Time.now |> Task.perform OnStartTime )

        OnStartTime now ->
            case model.state of
                Ready readyModel ->
                    let
                        m =
                            mkActiveModel readyModel now
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
                                ( { model | state = Finished <| mkFinishedModel state }
                                , Ports.sendToPort <| Announce "Finished - well done"
                                )

                    else
                        ( { model | state = Active state_ }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Cancel ->
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

            Finished m ->
                viewFinished model.zone m


viewChoosing : ChoosingModel -> List (Html Msg)
viewChoosing m =
    let
        mkItem : Int -> List SchemaElement -> Html Msg
        mkItem idx schema =
            li
                [ class <| ifThenElse (Just idx == m.selectedIndex) "pure-menu-item selected" "pure-menu-item"
                , onClick <| SelectSchema schema
                ]
                (schema |> L.map viewActivity2)

        days =
            startToRun
                |> L.indexedMap (\idx flts -> mkItem idx <| mkSchema flts)
                |> ul [ class "pure-menu-list" ]
    in
    [ h1 [] [ text "Choose schema" ]
    , div [ class "pure-menu custom-restricted-width" ] [ days ]
    , div []
        [ text "5 min warm up"
        , input [ type_ "checkbox", onCheck ToggleWarmUp, checked m.add5MinWarmUp ] []
        ]
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

        toGo : Float
        toGo =
            m.activity |> Zipper.current |> .cumulative |> (\cum -> cum - m.elapsed)
    in
    [ h1 [] [ text "Active" ]
    , div []
        [ text "Started at:"
        , viewTime zone m.begin
        ]
    , div [ class "xl" ] [ text <| String.fromInt (round <| toGo / 1000) ]
    , before ++ current :: after |> ul []
    , div []
        [ mkButton Cancel "Cancel"
        , mkButton Pause "Pause"
        ]
    , div [] [ text <| Debug.toString m.wayPoints ]
    ]


viewFinished : Zone -> FinishedModel -> List (Html msg)
viewFinished zone m =
    [ h1 [] [ text "Finished" ]
    , viewTime zone m.begin
    , text <| Debug.toString m.wayPoints
    ]



-- View Helpers


viewTime : Zone -> Posix -> Html msg
viewTime zone posix =
    text <| DF.format [ DF.hourMilitaryFixed, DF.text ":", DF.minuteFixed, DF.text ":", DF.secondFixed ] zone posix


viewActivity : String -> SchemaElement -> Html msg
viewActivity cls item =
    li [ class cls ] [ text <| String.fromFloat item.time ++ " mins " ++ Debug.toString item.activity ]


viewActivity2 : SchemaElement -> Html msg
viewActivity2 item =
    let
        t =
            String.fromFloat item.time

        cls =
            case item.activity of
                Walking ->
                    "font-large bg-white"

                Running ->
                    "font-large bg-red"
    in
    div
        [ class cls
        , style "flex-grow" t
        ]
        [ text t ]


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
