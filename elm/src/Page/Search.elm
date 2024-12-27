module Page.Search exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Search
import Types exposing (Msg(..), SearchState)
import Ui


view : String -> SearchState -> Html Msg
view team state =
    div [ Ui.pageStyle ]
        [ Ui.viewNav "search"
        , h2 [] [ text "Algorithmes de recherche" ]
        , p [ Ui.subtleStyle ] [ text ("Équipe : " ++ team) ]
        , Ui.viewSelect
            "Algorithme"
            (List.map (\a -> ( algoKey a, Search.algorithmName a )) Search.allAlgorithms)
            (algoKey state.algorithm)
            (\s -> SearchAlgorithmSelected (parseAlgo s))
        , Ui.viewSelect
            "Nombre max"
            (List.map (\s -> ( String.fromInt s, Ui.formatNumber s )) Search.searchSizes)
            (String.fromInt state.max)
            (\s -> SearchMaxSelected (String.toInt s |> Maybe.withDefault 1000))
        , button
            [ onClick SearchRun, disabled state.running, Ui.btnStyle ]
            [ text
                (if state.running then
                    "En cours…"

                 else
                    "Lancer"
                )
            ]
        , Ui.viewResult state.result
            (\count ->
                [ ( "Algorithme", Search.algorithmName state.algorithm )
                , ( "Nombre max", Ui.formatNumber state.max )
                , ( "Nombre d'essais", Ui.formatNumber count )
                ]
            )
        ]


algoKey : Search.Algorithm -> String
algoKey algo =
    case algo of
        Search.Dichotomy ->
            "dichotomy"

        Search.Sequential ->
            "sequential"

        Search.ShuffledSequential ->
            "shuffled"

        Search.CompletelyRandom ->
            "random"


parseAlgo : String -> Search.Algorithm
parseAlgo s =
    case s of
        "sequential" ->
            Search.Sequential

        "shuffled" ->
            Search.ShuffledSequential

        "random" ->
            Search.CompletelyRandom

        _ ->
            Search.Dichotomy
