module Page.Stats exposing (view)

import Chart
import Html exposing (..)
import Html.Attributes exposing (..)
import Time
import Types exposing (Msg, Stat)
import Ui


view : String -> List Stat -> Time.Posix -> Time.Zone -> Bool -> Html Msg
view team allStats now zone logScale =
    let
        teamStats =
            List.filter (\s -> s.team == team) allStats
    in
    div [ Ui.pageStyle ]
        [ Ui.viewNav "stats"
        , h2 [] [ text "Statistiques" ]
        , p [ Ui.subtleStyle ] [ text ("Équipe : " ++ team) ]
        , if List.isEmpty teamStats then
            p [] [ text "Aucun résultat pour l'instant." ]

          else
            div []
                [ Chart.viewChart logScale teamStats
                , table
                    [ style "width" "100%"
                    , style "border-collapse" "collapse"
                    , style "margin-top" "20px"
                    ]
                    [ thead []
                        [ tr []
                            [ th [ Ui.thStyle, style "text-align" "left" ] [ text "Algorithme" ]
                            , th [ Ui.thStyle, style "text-align" "right" ] [ text "n" ]
                            , th [ Ui.thStyle, style "text-align" "right" ] [ text "Résultat" ]
                            , th [ Ui.thStyle, style "text-align" "right" ] [ text "Quand" ]
                            ]
                        ]
                    , tbody [] (List.map (viewRow now zone) teamStats)
                    ]
                ]
        ]


viewRow : Time.Posix -> Time.Zone -> Stat -> Html Msg
viewRow now zone stat =
    tr []
        [ td [ Ui.tdStyle ] [ text stat.algorithm ]
        , td [ Ui.tdStyle, style "text-align" "right" ] [ text (Ui.formatNumber stat.n) ]
        , td [ Ui.tdStyle, style "text-align" "right" ] [ text (Ui.formatNumber stat.result) ]
        , td [ Ui.tdStyle, style "text-align" "right", style "color" "#888" ]
            [ text (Ui.formatTimestamp now zone (Time.millisToPosix stat.timestamp)) ]
        ]
