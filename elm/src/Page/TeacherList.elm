module Page.TeacherList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time
import Types exposing (Msg(..), Stat)
import Ui


view : Maybe String -> List Stat -> Time.Posix -> Time.Zone -> Html Msg
view teacherEmail stats now zone =
    let
        isTeacher =
            teacherEmail /= Nothing

        maxStatsList =
            List.foldl
                (\stat acc ->
                    let
                        sameGroup s =
                            s.team == stat.team && s.algorithm == stat.algorithm && s.n == stat.n
                    in
                    case List.partition sameGroup acc of
                        ( [], rest ) ->
                            stat :: rest

                        ( existing :: _, rest ) ->
                            (if stat.result > existing.result then
                                stat

                             else
                                existing
                            )
                                :: rest
                )
                []
                stats
    in
    div [ Ui.pageStyle ]
        [ nav [ style "margin-bottom" "24px" ]
            [ button [ onClick GoToTeacher, Ui.navBtnStyle ] [ text "← Graphique" ] ]
        , h2 [] [ text "Vue enseignant" ]
        , if List.isEmpty stats then
            p [] [ text "Aucun résultat pour l'instant." ]

          else
            div []
                [ viewSection "Meilleures performances" maxStatsList now zone isTeacher
                , viewSection "Toutes les entrées" stats now zone isTeacher
                ]
        ]


viewSection : String -> List Stat -> Time.Posix -> Time.Zone -> Bool -> Html Msg
viewSection title statsList now zone isTeacher =
    div [ style "margin-top" "32px" ]
        [ h3 [ style "margin-bottom" "8px" ] [ text title ]
        , table
            [ style "width" "100%"
            , style "border-collapse" "collapse"
            ]
            [ thead []
                [ tr []
                    [ th [ Ui.thStyle, style "text-align" "left" ] [ text "Équipe" ]
                    , th [ Ui.thStyle, style "text-align" "left" ] [ text "Algorithme" ]
                    , th [ Ui.thStyle, style "text-align" "right" ] [ text "n" ]
                    , th [ Ui.thStyle, style "text-align" "right" ] [ text "Résultat" ]
                    , th [ Ui.thStyle, style "text-align" "right" ] [ text "Quand" ]
                    , th [ Ui.thStyle ] []
                    ]
                ]
            , tbody [] (List.map (viewRow now zone isTeacher) statsList)
            ]
        ]


viewRow : Time.Posix -> Time.Zone -> Bool -> Stat -> Html Msg
viewRow now zone isTeacher stat =
    tr []
        [ td [ Ui.tdStyle ] [ text stat.team ]
        , td [ Ui.tdStyle ] [ text stat.algorithm ]
        , td [ Ui.tdStyle, style "text-align" "right" ] [ text (Ui.formatNumber stat.n) ]
        , td [ Ui.tdStyle, style "text-align" "right" ] [ text (Ui.formatNumber stat.result) ]
        , td [ Ui.tdStyle, style "text-align" "right", style "color" "#888" ]
            [ text (Ui.formatTimestamp now zone (Time.millisToPosix stat.timestamp)) ]
        , td [ Ui.tdStyle, style "text-align" "right" ]
            [ if isTeacher then
                button [ onClick (DeleteStat stat.id), Ui.deleteBtnStyle ] [ text "×" ]

              else
                text ""
            ]
        ]
