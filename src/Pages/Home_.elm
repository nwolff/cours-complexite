module Pages.Home_ exposing (Model, Msg, page)

import Firestore
import Firestore.Config as Config
import Firestore.Decode as FSDecode
import Firestore.Encode as FSEncode
import Gen.Params.Home_ exposing (Params)
import Page
import Request
import Result.Extra as ExResult
import Shared
import Task
import Time
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }



-- model


type alias Model =
    { firestore : Firestore.Firestore
    , document : Maybe (Firestore.Document Stat)
    }


type alias Stat =
    { timestamp : Time.Posix
    , team : String
    , algorithm : String
    , problem_size : Int
    , step_count : Int
    }



-- init


init : ( Model, Cmd Msg )
init =
    let
        firestore =
            Config.new
                { apiKey = ""
                , project = "cours-complexite-446113"
                }
                |> Config.withDatabase "stats"
                |> Firestore.init
    in
    ( { firestore = firestore, document = Nothing }
    , firestore
        |> Firestore.root
        |> Firestore.collection "stats"
        |> Firestore.document "stat1"
        |> Firestore.build
        |> ExResult.toTask
        |> Task.andThen (Firestore.get decoder)
        |> Task.attempt GotDocument
    )


decoder : FSDecode.Decoder Stat
decoder =
    FSDecode.document Stat
        |> FSDecode.required "timestamp" FSDecode.timestamp
        |> FSDecode.required "team" FSDecode.string
        |> FSDecode.required "algorithm" FSDecode.string
        |> FSDecode.required "problem_size" FSDecode.int
        |> FSDecode.required "step_count" FSDecode.int


encoder : Stat -> FSEncode.Encoder
encoder stat =
    FSEncode.document
        [ ( "timestamp", FSEncode.timestamp stat.timestamp )
        , ( "team", FSEncode.string stat.team )
        , ( "algorithm", FSEncode.string stat.algorithm )
        , ( "problem_size", FSEncode.int stat.problem_size )
        , ( "step_count", FSEncode.int stat.step_count )
        ]



-- update


type Msg
    = GotDocument (Result Firestore.Error (Firestore.Document Stat))
    | SaveDocument Stat


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveDocument doc ->
            ( model
            , model.firestore
                |> Firestore.root
                |> Firestore.collection "stats"
                |> Firestore.document "stat1"
                |> Firestore.build
                |> ExResult.toTask
                |> ExResult.toTask
                |> Task.andThen (Firestore.insert decoder (encoder doc))
                |> Task.attempt GotDocument
            )

        GotDocument result ->
            case result of
                Ok document ->
                    ( { model | document = Just document }, Cmd.none )

                -- XXX
                Err _ ->
                    ( model, Cmd.none )



-- view


view : Model -> View Msg
view model =
    View.placeholder "FirestoreTest"
