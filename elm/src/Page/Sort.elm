module Page.Sort exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Sort
import Types exposing (Msg(..), SortState)
import Ui


view : String -> SortState -> Html Msg
view team state =
    div [ Ui.pageStyle ]
        [ Ui.viewNav "sort"
        , h2 [] [ text "Algorithmes de tri" ]
        , p [ Ui.subtleStyle ] [ text ("Équipe : " ++ team) ]
        , Ui.viewSelect
            "Algorithme"
            (List.map (\a -> ( algoKey a, Sort.algorithmName a )) Sort.allAlgorithms)
            (algoKey state.algorithm)
            (\s -> SortAlgorithmSelected (parseAlgo s))
        , Ui.viewSelect
            "Taille de la liste"
            (List.map (\s -> ( String.fromInt s, Ui.formatNumber s )) Sort.sortSizes)
            (String.fromInt state.size)
            (\s -> SortSizeSelected (String.toInt s |> Maybe.withDefault 1000))
        , button
            [ onClick SortRun, disabled state.running, Ui.btnStyle ]
            [ text
                (if state.running then
                    "En cours…"

                 else
                    "Lancer"
                )
            ]
        , Ui.viewResult state.result
            (\count ->
                [ ( "Algorithme", Sort.algorithmName state.algorithm )
                , ( "Taille de la liste", Ui.formatNumber state.size )
                , ( "Nombre d'opérations", Ui.formatNumber count )
                ]
            )
        ]


algoKey : Sort.Algorithm -> String
algoKey algo =
    case algo of
        Sort.InsertionSort ->
            "insertion"

        Sort.MergeSort ->
            "merge"


parseAlgo : String -> Sort.Algorithm
parseAlgo s =
    case s of
        "insertion" ->
            Sort.InsertionSort

        _ ->
            Sort.MergeSort
