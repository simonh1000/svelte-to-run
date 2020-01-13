module Main exposing (..)

import Browser
import Common.CoreHelpers exposing (addSuffixIf, formatPluralRegular, ifThenElse)
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


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { blankModel | state = ChooseSchema <| mkChoosingModel flags }
    , Time.here |> Task.perform OnTimeZone
    )



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = SelectSchema (List SchemaElement)
    | ToggleWarmUp Bool
    | ToggleDevMode Bool
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

        ToggleDevMode devMode ->
            ( { model | state = mapChoosing (\m -> { m | devMode = devMode }) model.state }, Cmd.none )

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
                                , finishCmd
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


finishCmd =
    Cmd.batch
        [ Ports.sendToPort <| Speak "Finished - well done"
        , Ports.sendToPort Finish
        ]



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
            { txt = "Now " ++ convert elem ++ " for " ++ formatPluralRegular (round elem.time) "minute"
            , mins = round <| elem.time / 1000
            , activity = elem.activity
            }
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
    div [ class "p-6" ] <|
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


{-| schemas are showed with absolute sizes
-}
viewChoosing : ChoosingModel -> List (Html Msg)
viewChoosing m =
    let
        days =
            m.runs
                |> L.indexedMap (viewDayRun m)
                |> ul [ class "schemas" ]

        cls isSelected =
            if isSelected then
                "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mr-2"

            else
                "bg-blue-100 hover:bg-blue-300 text-black font-bold py-2 px-4 rounded mr-2"

        mkToggle msg isSelected txt =
            span []
                [ label
                    [ for txt
                    , class <| cls isSelected
                    ]
                    [ text txt, ifThenElse isSelected (text "!") (text "") ]
                , input
                    [ id txt
                    , type_ "checkbox"
                    , onCheck msg
                    , checked isSelected
                    , class "hidden"
                    ]
                    []
                ]
    in
    [ h1 [] [ text "Choose schema" ]
    , div [] [ days ]
    , div []
        [ mkToggle ToggleWarmUp m.add5MinWarmUp "5 min warm up"
        , mkToggle ToggleDevMode m.devMode "dev mode"
        ]
    ]


viewDayRun : ChoosingModel -> Int -> DayRun -> Html Msg
viewDayRun m idx dayRun =
    let
        schema_ =
            dayRunToSchema dayRun.schema

        tot =
            dayRun.schema |> L.map Tuple.first |> L.sum |> round |> String.fromInt
    in
    li
        [ class <| addSuffixIf (Just idx == m.selectedIndex) " selected" "flex flex-col mb-2" ]
        [ h3 []
            [ text dayRun.title
            , span [ class "ml-1" ] [ text <| "(" ++ tot ++ " mins)" ]
            ]
        , div
            [ class "flex flex-row self-start"
            , onClick <| SelectSchema schema_
            ]
            (L.map (viewActivityAbs "") schema_)
        ]



-- READY


viewReady : ReadyModel -> List (Html Msg)
viewReady m =
    [ h1 [] [ text "Ready" ]
    , m.activity
        |> viewSchemaFlex ""
    , div [] [ mkButton Start "start-button" "Start" ]
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
        [ mkButton Cancel "unused" "Cancel"
        , mkButton Pause "unused" "Pause"
        ]
    , div [ class "mt-6 text-xs" ] [ text <| Debug.toString m.wayPoints ]
    ]


viewFinished : Zone -> FinishedModel -> List (Html msg)
viewFinished zone m =
    [ h1 [] [ text "Finished" ]
    , viewTime zone m.begin
    , div [ class "mt-6 text-xs" ] [ text <| Debug.toString m.wayPoints ]
    ]



-- View Helpers


viewTime : Zone -> Posix -> Html msg
viewTime zone posix =
    text <| DF.format [ DF.hourMilitaryFixed, DF.text ":", DF.minuteFixed, DF.text ":", DF.secondFixed ] zone posix


viewSchemeZipper : Zipper SchemaElement -> Html msg
viewSchemeZipper items =
    let
        before =
            Zipper.before items |> L.map (viewActivityFlex "before")

        current =
            Zipper.current items |> viewActivityFlex "current"

        after =
            Zipper.after items |> L.map (viewActivityFlex "after")
    in
    before ++ current :: after |> div [ class "flex flex-row" ]


viewSchemaFlex : String -> List SchemaElement -> Html msg
viewSchemaFlex cls items =
    items |> L.map (viewActivityFlex cls) |> div [ class "flex flex-row self-start h-10" ]


viewActivityFlex : String -> SchemaElement -> Html msg
viewActivityFlex cls item =
    let
        t =
            String.fromFloat item.time

        baseCls =
            "flex flex-row flex-grow items-center justify-center font-large "
    in
    div
        [ mkClass baseCls cls item.activity
        , style "flex-grow" t
        ]
        [ text t ]


viewActivityAbs : String -> SchemaElement -> Html msg
viewActivityAbs cls item =
    let
        t =
            String.fromFloat item.time

        width =
            String.fromFloat (item.time * 15) ++ "px"

        baseCls =
            "flex flex-row items-center justify-center font-large "
    in
    div
        [ mkClass baseCls cls item.activity
        , style "width" width
        ]
        [ text t ]


mkClass : String -> String -> Activity -> Attribute msg
mkClass baseCls cls activity =
    class <|
        case activity of
            Walking ->
                baseCls ++ cls ++ " bg-white"

            Running ->
                baseCls ++ cls ++ " bg-red-600"


mkButton : msg -> String -> String -> Html msg
mkButton msg id_ txt =
    button
        [ id id_
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


main : Program Flags Model Msg
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
