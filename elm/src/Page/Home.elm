module Page.Home exposing (view, viewTeamHome)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (HomeState, Msg(..))
import Ui


view : HomeState -> Html Msg
view state =
    div [ Ui.pageStyle ]
        [ h1 [] [ text "Complexité des algorithmes" ]
        , p [] [ text "Entrez le nom de votre équipe pour commencer." ]
        , input
            [ type_ "text"
            , placeholder "Nom d'équipe (min. 3 caractères)"
            , value state.input
            , onInput HomeInputChanged
            , Ui.onEnter HomeSubmit
            , Ui.inputStyle
            ]
            []
        , Ui.viewError state.error
        , button [ onClick HomeSubmit, Ui.btnStyle ] [ text "Commencer" ]
        , p [ style "margin-top" "40px", style "display" "flex", style "justify-content" "space-between" ]
            [ a
                [ onClick GoToTeacher
                , href "#"
                , style "color" "#888"
                , style "font-size" "0.85rem"
                ]
                [ text "Vue enseignant →" ]
            , a
                [ href "about.html"
                , target "_blank"
                , style "color" "#adb5bd"
                , style "text-decoration" "none"
                , title "À propos"
                ]
                [ text "ⓘ" ]
            ]
        ]


viewTeamHome : String -> Html Msg
viewTeamHome team =
    div [ Ui.pageStyle ]
        [ h1 [] [ text "Complexité des algorithmes" ]
        , p [] [ text ("Équipe : " ++ team) ]
        , p [] [ text "Que voulez-vous faire ?" ]
        , div [ attribute "style" "display:flex;gap:12px;flex-wrap:wrap" ]
            [ button [ onClick GoToSort, Ui.btnStyle ] [ text "Tris" ]
            , button [ onClick GoToSearch, Ui.btnStyle ] [ text "Recherches" ]
            , button [ onClick GoToGame, Ui.btnStyle ] [ text "Jeu" ]
            , button [ onClick GoToStats, Ui.btnStyle ] [ text "Statistiques" ]
            ]
        ]
