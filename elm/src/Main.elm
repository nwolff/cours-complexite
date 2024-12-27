port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Page.Game
import Page.Home
import Page.Search
import Page.Sort
import Page.Stats
import Page.Teacher
import Page.TeacherList
import Random
import Search
import Sort
import Task
import Time
import Types exposing (..)
import Ui
import Url
import Url.Parser exposing ((</>))



-- PORTS


port saveResult : Encode.Value -> Cmd msg


port receivedStats : (Decode.Value -> msg) -> Sub msg


port firestoreError : (String -> msg) -> Sub msg


port signInWithGoogle : () -> Cmd msg


port signOutTeacher : () -> Cmd msg


port receivedAuthState : (Maybe String -> msg) -> Sub msg


port deleteDoc : String -> Cmd msg



-- MODEL


type alias Model =
    { key : Nav.Key
    , team : String
    , page : Page
    , stats : List Stat
    , firestoreErr : Maybe String
    , currentTime : Time.Posix
    , timezone : Time.Zone
    , teacherEmail : Maybe String
    , chartLogScale : Bool
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( team, page ) =
            routeToTeamPage (Url.Parser.parse routeParser url |> Maybe.withDefault HomeRoute)
    in
    ( { key = key
      , team = team
      , page = page
      , stats = []
      , firestoreErr = Nothing
      , currentTime = Time.millisToPosix 0
      , timezone = Time.utc
      , teacherEmail = Nothing
      , chartLogScale = False
      }
    , Cmd.batch
        [ Task.perform Tick Time.now
        , Task.perform GotTimezone Time.here
        ]
    )



-- ROUTING


routeParser : Url.Parser.Parser (Route -> a) a
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.map HomeRoute Url.Parser.top
        , Url.Parser.map TeacherListRoute (Url.Parser.s "teacher" </> Url.Parser.s "list")
        , Url.Parser.map TeacherRoute (Url.Parser.s "teacher")
        , Url.Parser.map StatsRoute (Url.Parser.string </> Url.Parser.s "stats")
        , Url.Parser.map SortRoute (Url.Parser.string </> Url.Parser.s "sort")
        , Url.Parser.map SearchRoute (Url.Parser.string </> Url.Parser.s "search")
        , Url.Parser.map GameRoute (Url.Parser.string </> Url.Parser.s "game")
        , Url.Parser.map TeamRoute Url.Parser.string
        ]


routeToTeamPage : Route -> ( String, Page )
routeToTeamPage route =
    case route of
        HomeRoute ->
            ( "", HomePg { input = "", error = Nothing } )

        TeacherRoute ->
            ( "", TeacherPg )

        TeacherListRoute ->
            ( "", TeacherListPg )

        TeamRoute raw ->
            ( decode raw, TeamHomePg )

        SortRoute raw ->
            ( decode raw
            , SortPg { algorithm = Sort.QuickSort, size = 1000, result = Nothing, running = False }
            )

        SearchRoute raw ->
            ( decode raw
            , SearchPg { algorithm = Search.Dichotomy, max = 1000, result = Nothing, running = False }
            )

        GameRoute raw ->
            ( decode raw
            , GamePg { max = 100, secret = Nothing, input = "", guesses = 0, feedback = Nothing, won = False }
            )

        StatsRoute raw ->
            ( decode raw, StatsPg )


decode : String -> String
decode raw =
    Url.percentDecode raw |> Maybe.withDefault raw



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            let
                ( team, page ) =
                    routeToTeamPage (Url.Parser.parse routeParser url |> Maybe.withDefault HomeRoute)
            in
            ( { model
                | page = page
                , team =
                    if String.isEmpty team then
                        model.team

                    else
                        team
              }
            , Cmd.none
            )

        LinkClicked req ->
            case req of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        HomeInputChanged s ->
            case model.page of
                HomePg state ->
                    ( { model | page = HomePg { state | input = s } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        HomeSubmit ->
            case model.page of
                HomePg state ->
                    let
                        team =
                            String.trim state.input
                    in
                    if String.length team >= 3 then
                        ( model, Nav.pushUrl model.key ("/" ++ Url.percentEncode team) )

                    else
                        ( { model | page = HomePg { state | error = Just "Le nom d'équipe doit avoir au minimum 3 caractères" } }
                        , Cmd.none
                        )

                _ ->
                    ( model, Cmd.none )

        GoToTeamHome ->
            ( model, Nav.pushUrl model.key ("/" ++ Url.percentEncode model.team) )

        GoToSort ->
            ( model, Nav.pushUrl model.key ("/" ++ Url.percentEncode model.team ++ "/sort") )

        GoToSearch ->
            ( model, Nav.pushUrl model.key ("/" ++ Url.percentEncode model.team ++ "/search") )

        GoToGame ->
            ( model, Nav.pushUrl model.key ("/" ++ Url.percentEncode model.team ++ "/game") )

        GoToStats ->
            ( model, Nav.pushUrl model.key ("/" ++ Url.percentEncode model.team ++ "/stats") )

        GoToTeacher ->
            ( model, Nav.pushUrl model.key "/teacher" )

        GoToTeacherList ->
            ( model, Nav.pushUrl model.key "/teacher/list" )

        SortAlgorithmSelected algo ->
            case model.page of
                SortPg state ->
                    ( { model | page = SortPg { state | algorithm = algo, result = Nothing } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SortSizeSelected size ->
            case model.page of
                SortPg state ->
                    ( { model | page = SortPg { state | size = size, result = Nothing } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SortRun ->
            case model.page of
                SortPg state ->
                    ( { model | page = SortPg { state | running = True, result = Nothing } }
                    , Random.generate GotSortList
                        (Random.list state.size (Random.int 0 (state.size - 1)))
                    )

                _ ->
                    ( model, Cmd.none )

        GotSortList lst ->
            case model.page of
                SortPg state ->
                    let
                        count =
                            Sort.run state.algorithm lst
                    in
                    ( { model | page = SortPg { state | result = Just count, running = False } }
                    , saveResult
                        (Encode.object
                            [ ( "team", Encode.string model.team )
                            , ( "algorithm", Encode.string (Sort.algorithmName state.algorithm) )
                            , ( "n", Encode.int state.size )
                            , ( "result", Encode.int count )
                            ]
                        )
                    )

                _ ->
                    ( model, Cmd.none )

        SearchAlgorithmSelected algo ->
            case model.page of
                SearchPg state ->
                    ( { model | page = SearchPg { state | algorithm = algo, result = Nothing } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SearchMaxSelected max ->
            case model.page of
                SearchPg state ->
                    ( { model | page = SearchPg { state | max = max, result = Nothing } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SearchRun ->
            case model.page of
                SearchPg state ->
                    ( { model | page = SearchPg { state | running = True, result = Nothing } }
                    , Random.generate GotSearchSetup
                        (Search.setupGenerator state.algorithm state.max)
                    )

                _ ->
                    ( model, Cmd.none )

        GotSearchSetup setup ->
            case model.page of
                SearchPg state ->
                    let
                        count =
                            Search.run state.algorithm state.max setup
                    in
                    ( { model | page = SearchPg { state | result = Just count, running = False } }
                    , saveResult
                        (Encode.object
                            [ ( "team", Encode.string model.team )
                            , ( "algorithm", Encode.string (Search.algorithmName state.algorithm) )
                            , ( "n", Encode.int state.max )
                            , ( "result", Encode.int count )
                            ]
                        )
                    )

                _ ->
                    ( model, Cmd.none )

        GameMaxSelected max ->
            case model.page of
                GamePg state ->
                    ( { model | page = GamePg { state | max = max } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GameStart ->
            case model.page of
                GamePg state ->
                    ( { model | page = GamePg { state | secret = Nothing, input = "", guesses = 0, feedback = Nothing, won = False } }
                    , Random.generate GotGameSecret (Random.int 1 state.max)
                    )

                _ ->
                    ( model, Cmd.none )

        GotGameSecret n ->
            case model.page of
                GamePg state ->
                    ( { model | page = GamePg { state | secret = Just n } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GameInputChanged s ->
            case model.page of
                GamePg state ->
                    ( { model | page = GamePg { state | input = s } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GameGuess ->
            case model.page of
                GamePg state ->
                    case ( String.toInt state.input, state.secret ) of
                        ( Just n, Just secret ) ->
                            let
                                newGuesses =
                                    state.guesses + 1
                            in
                            case compare n secret of
                                EQ ->
                                    ( { model | page = GamePg { state | guesses = newGuesses, won = True, input = "" } }
                                    , saveResult
                                        (Encode.object
                                            [ ( "team", Encode.string model.team )
                                            , ( "algorithm", Encode.string "Humain" )
                                            , ( "n", Encode.int state.max )
                                            , ( "result", Encode.int newGuesses )
                                            ]
                                        )
                                    )

                                LT ->
                                    ( { model | page = GamePg { state | guesses = newGuesses, feedback = Just "Plus grand !", input = "" } }
                                    , Cmd.none
                                    )

                                GT ->
                                    ( { model | page = GamePg { state | guesses = newGuesses, feedback = Just "Plus petit !", input = "" } }
                                    , Cmd.none
                                    )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ReceivedStatsMsg value ->
            ( { model | stats = decodeStats value, firestoreErr = Nothing }, Cmd.none )

        FirestoreError err ->
            ( { model | firestoreErr = Just err }, Cmd.none )

        Tick t ->
            ( { model | currentTime = t }, Cmd.none )

        GotTimezone zone ->
            ( { model | timezone = zone }, Cmd.none )

        SignInTeacher ->
            ( model, signInWithGoogle () )

        SignOutTeacher ->
            ( model, signOutTeacher () )

        GotAuthState maybeEmail ->
            ( { model | teacherEmail = maybeEmail }, Cmd.none )

        DeleteStat docId ->
            ( model, deleteDoc docId )

        DeleteAllStats ->
            ( model, Cmd.batch (List.map (\stat -> deleteDoc stat.id) model.stats) )

        ToggleChartScale ->
            ( { model | chartLogScale = not model.chartLogScale }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ receivedStats ReceivedStatsMsg
        , firestoreError FirestoreError
        , Time.every 30000 Tick
        , receivedAuthState GotAuthState
        ]



-- JSON


decodeStat : Decode.Decoder Stat
decodeStat =
    Decode.map6 Stat
        (Decode.field "id" Decode.string)
        (Decode.field "team" Decode.string)
        (Decode.field "algorithm" Decode.string)
        (Decode.field "n" Decode.int)
        (Decode.field "result" Decode.int)
        (Decode.field "timestamp" Decode.int |> Decode.maybe |> Decode.map (Maybe.withDefault 0))


decodeStats : Decode.Value -> List Stat
decodeStats value =
    value
        |> Decode.decodeValue (Decode.list decodeStat)
        |> Result.withDefault []



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Complexité des algorithmes"
    , body = [ viewBody model ]
    }


viewBody : Model -> Html Msg
viewBody model =
    div []
        [ Ui.viewFirestoreError model.firestoreErr
        , case model.page of
            HomePg state ->
                Page.Home.view state

            TeamHomePg ->
                Page.Home.viewTeamHome model.team

            SortPg state ->
                Page.Sort.view model.team state

            SearchPg state ->
                Page.Search.view model.team state

            GamePg state ->
                Page.Game.view model.team state

            StatsPg ->
                Page.Stats.view model.team model.stats model.currentTime model.timezone model.chartLogScale

            TeacherPg ->
                Page.Teacher.view model.teacherEmail model.stats model.currentTime model.timezone model.chartLogScale

            TeacherListPg ->
                Page.TeacherList.view model.teacherEmail model.stats model.currentTime model.timezone
        ]



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
