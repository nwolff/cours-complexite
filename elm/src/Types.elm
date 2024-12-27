module Types exposing
    ( GameState
    , HomeState
    , Msg(..)
    , Page(..)
    , Route(..)
    , SearchState
    , SortState
    , Stat
    )

import Browser
import Json.Decode as Decode
import Search
import Sort
import Time
import Url


type alias Stat =
    { id : String
    , team : String
    , algorithm : String
    , n : Int
    , result : Int
    , timestamp : Int
    }


type Page
    = HomePg HomeState
    | TeamHomePg
    | SortPg SortState
    | SearchPg SearchState
    | GamePg GameState
    | StatsPg
    | TeacherPg
    | TeacherListPg


type Route
    = HomeRoute
    | TeacherRoute
    | TeamRoute String
    | SortRoute String
    | SearchRoute String
    | GameRoute String
    | StatsRoute String
    | TeacherListRoute


type alias HomeState =
    { input : String
    , error : Maybe String
    }


type alias SortState =
    { algorithm : Sort.Algorithm
    , size : Int
    , result : Maybe Int
    , running : Bool
    }


type alias SearchState =
    { algorithm : Search.Algorithm
    , max : Int
    , result : Maybe Int
    , running : Bool
    }


type alias GameState =
    { max : Int
    , secret : Maybe Int
    , input : String
    , guesses : Int
    , feedback : Maybe String
    , won : Bool
    }


type Msg
    = UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | HomeInputChanged String
    | HomeSubmit
    | GoToSort
    | GoToSearch
    | GoToGame
    | GoToStats
    | GoToTeamHome
    | GoToTeacher
    | GoToTeacherList
    | SortAlgorithmSelected Sort.Algorithm
    | SortSizeSelected Int
    | SortRun
    | GotSortList (List Int)
    | SearchAlgorithmSelected Search.Algorithm
    | SearchMaxSelected Int
    | SearchRun
    | GotSearchSetup Search.Setup
    | ReceivedStatsMsg Decode.Value
    | FirestoreError String
    | Tick Time.Posix
    | GotTimezone Time.Zone
    | SignInTeacher
    | SignOutTeacher
    | GotAuthState (Maybe String)
    | DeleteStat String
    | DeleteAllStats
    | ToggleChartScale
    | GameMaxSelected Int
    | GameStart
    | GotGameSecret Int
    | GameInputChanged String
    | GameGuess
