module Page.Teacher exposing (view)

import Chart
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time
import Types exposing (Msg(..), Stat)
import Ui
import Url


view : Maybe String -> List Stat -> Time.Posix -> Time.Zone -> Bool -> Html Msg
view teacherEmail stats _ _ logScale =
    div [ Ui.pageStyle ]
        [ nav [ style "margin-bottom" "24px" ]
            [ a
                [ href "/"
                , attribute "style" "color:#333;text-decoration:none;font-family:system-ui,sans-serif"
                ]
                [ text "← Accueil" ]
            ]
        , h2 [] [ text "Vue enseignant" ]
        , viewAuth teacherEmail
        , if List.isEmpty stats then
            p [] [ text "Aucun résultat pour l'instant." ]

          else
            div []
                [ Chart.viewChart logScale stats
                , div [ style "margin-top" "16px", style "display" "flex", style "gap" "8px" ]
                    [ viewCsvDownload "Meilleures_performances" (maxStats stats)
                    , viewCsvDownload "Toutes_les_entrées" stats
                    , button [ onClick GoToTeacherList, Ui.btnStyle ] [ text "Voir la liste →" ]
                    ]
                ]
        ]


viewCsvDownload : String -> List Stat -> Html msg
viewCsvDownload filename statsList =
    a
        [ href ("data:text/csv;charset=utf-8," ++ Url.percentEncode (toCsv statsList))
        , download (filename ++ ".csv")
        , Ui.btnStyle
        , attribute "style" "padding:8px 18px;font-size:1rem;cursor:pointer;border:1px solid #aaa;border-radius:4px;background:#fff;text-decoration:none;color:inherit"
        ]
        [ text ("↓ " ++ String.replace "_" " " filename) ]


toCsv : List Stat -> String
toCsv stats =
    let
        header =
            "équipe,algorithme,n,résultat"

        row s =
            csvField s.team ++ "," ++ csvField s.algorithm ++ "," ++ String.fromInt s.n ++ "," ++ String.fromInt s.result
    in
    String.join "\n" (header :: List.map row stats)


csvField : String -> String
csvField s =
    if String.contains "," s || String.contains "\"" s then
        "\"" ++ String.replace "\"" "\"\"" s ++ "\""

    else
        s


maxStats : List Stat -> List Stat
maxStats stats =
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


viewAuth : Maybe String -> Html Msg
viewAuth maybeEmail =
    case maybeEmail of
        Nothing ->
            div [ style "margin-bottom" "20px" ]
                [ button [ onClick SignInTeacher, Ui.btnStyle ] [ text "Se connecter avec Google" ]
                , p
                    [ Ui.subtleStyle
                    , style "font-size" "0.85rem"
                    , style "margin-top" "6px"
                    ]
                    [ text "Connectez-vous pour pouvoir supprimer des entrées." ]
                ]

        Just email ->
            div
                [ style "margin-bottom" "20px"
                , style "display" "flex"
                , style "align-items" "center"
                , style "gap" "12px"
                ]
                [ span [ Ui.subtleStyle ] [ text email ]
                , button [ onClick SignOutTeacher, Ui.navBtnStyle ] [ text "Se déconnecter" ]
                , button [ onClick DeleteAllStats, Ui.deleteBtnStyle ] [ text "Tout supprimer" ]
                ]
