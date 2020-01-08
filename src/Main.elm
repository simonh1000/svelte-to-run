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
    div [ class "bg-gray-100 p-6" ] <|
        case model.state of
            ChooseSchema m ->
                viewChoosing m

            Ready m ->
                viewReady m

            Active m ->
                viewActive model.zone m

            Finished m ->
                viewFinished model.zone m



-- CHOOSING


viewChoosing : ChoosingModel -> List (Html Msg)
viewChoosing m =
    let
        mkItem : Int -> List SchemaElement -> Html Msg
        mkItem idx schema =
            li
                [ class <| ifThenElse (Just idx == m.selectedIndex) "mb-2 selected" "mb-2"
                , onClick <| SelectSchema schema
                ]
                [ viewSchemeList "" schema ]

        days =
            startToRun
                |> L.indexedMap (\idx flts -> mkItem idx <| mkSchema flts)
                |> ul [ class "schemas" ]
    in
    [ h1 [] [ text "Choose schema" ]
    , div [] [ days ]
    , div []
        [ label [ for "warmup" ] [ text "5 min warm up" ]
        , input
            [ id "warmup"
            , type_ "checkbox"
            , onCheck ToggleWarmUp
            , checked m.add5MinWarmUp
            ]
            []
        ]
    ]



-- READY


viewReady : ReadyModel -> List (Html Msg)
viewReady m =
    [ h1 [] [ text "Ready" ]
    , m.activity
        |> viewSchemeList ""
    , div [] [ mkButton Start "Start" ]
    , div [] [ text <| Debug.toString m.position ]
    ]



-- ACTIVE


viewActive : Zone -> ActiveModel -> List (Html Msg)
viewActive zone m =
    let
        curr =
            m.activity |> Zipper.current

        toGo =
            curr
                |> .cumulative
                |> (\cum -> cum - m.elapsed)
                |> (\flt -> String.fromInt (round <| flt / 1000))
    in
    [ h1 [] [ text "Active" ]
    , div []
        [ text "Started at:"
        , viewTime zone m.begin
        ]
    , div [ class "flex flex-col items-center" ]
        [ span [ class "text-6xl" ] [ text <| ppActivity curr.activity ]
        , span [ class "remaining ml-2" ] [ text toGo ]
        ]
    , viewSchemeZipper m.activity
    , div [ class "mt-6" ]
        [ mkButton Cancel "Cancel"
        , mkButton Pause "Pause"
        ]
    , div [ class "mt-6 text-xs" ] [ text <| Debug.toString m.wayPoints ]
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


viewSchemeZipper : Zipper SchemaElement -> Html msg
viewSchemeZipper items =
    let
        before =
            Zipper.before items |> L.map (viewActivity2 "before")

        current =
            Zipper.current items |> viewActivity2 "current"

        after =
            Zipper.after items |> L.map (viewActivity2 "after")
    in
    before ++ current :: after |> div [ class "flex flex-row" ]


viewSchemeList : String -> List SchemaElement -> Html msg
viewSchemeList cls items =
    items |> L.map (viewActivity2 cls) |> div [ class "flex flex-row" ]


viewActivity2 : String -> SchemaElement -> Html msg
viewActivity2 cls item =
    let
        t =
            String.fromFloat item.time

        baseCls =
            "flex-grow flex flex-row items-center justify-center font-large "

        cls_ =
            case item.activity of
                Walking ->
                    baseCls ++ cls ++ " bg-white"

                Running ->
                    baseCls ++ cls ++ " bg-red-600"
    in
    div
        [ class cls_
        , style "flex-grow" t
        ]
        [ text t ]


mkButton : msg -> String -> Html msg
mkButton msg txt =
    button
        [ id "start-button"
        , class "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mr-2"
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
