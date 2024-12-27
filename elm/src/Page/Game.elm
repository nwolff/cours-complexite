module Page.Game exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (GameState, Msg(..))
import Ui


gameSizes : List Int
gameSizes =
    [ 10, 100, 200, 300, 400, 500, 600, 700, 1000, 1500, 2000, 3000, 5000, 10000, 50000, 100000, 500000, 1000000 ]


view : String -> GameState -> Html Msg
view team state =
    div [ Ui.pageStyle ]
        [ Ui.viewNav "game"
        , h2 [] [ text "Jeu : devinez le nombre" ]
        , p [ Ui.subtleStyle ] [ text ("Équipe : " ++ team) ]
        , case state.secret of
            Nothing ->
                viewConfig state

            Just _ ->
                viewPlaying state
        ]


viewConfig : GameState -> Html Msg
viewConfig state =
    div []
        [ Ui.viewSelect
            "Borne supérieure"
            (List.map (\s -> ( String.fromInt s, Ui.formatNumber s )) gameSizes)
            (String.fromInt state.max)
            (\s -> GameMaxSelected (String.toInt s |> Maybe.withDefault 100))
        , button [ onClick GameStart, Ui.btnStyle ] [ text "Jouer" ]
        ]


viewPlaying : GameState -> Html Msg
viewPlaying state =
    div []
        [ p [] [ text ("Trouvez un nombre entre 1 et " ++ Ui.formatNumber state.max ++ ".") ]
        , if state.won then
            div []
                [ p [ style "color" "#27ae60", style "font-weight" "bold" ]
                    [ text ("Bingo ! Trouvé en " ++ String.fromInt state.guesses ++ " essais.") ]
                , button [ onClick GameStart, Ui.btnStyle ] [ text "Rejouer" ]
                ]

          else
            div []
                [ case state.feedback of
                    Just msg ->
                        p [ style "font-weight" "bold" ] [ text msg ]

                    Nothing ->
                        text ""
                , p [ Ui.subtleStyle ] [ text ("Essai n° " ++ String.fromInt (state.guesses + 1)) ]
                , input
                    [ type_ "number"
                    , value state.input
                    , onInput GameInputChanged
                    , Ui.onEnter GameGuess
                    , Ui.inputStyle
                    ]
                    []
                , button [ onClick GameGuess, Ui.btnStyle ] [ text "Deviner" ]
                ]
        ]
