module Ui exposing
    ( btnStyle
    , deleteBtnStyle
    , formatNumber
    , formatTimestamp
    , inputStyle
    , monthName
    , navBtnActiveStyle
    , navBtnStyle
    , onEnter
    , pageStyle
    , subtleStyle
    , tdStyle
    , thStyle
    , viewError
    , viewFirestoreError
    , viewNav
    , viewResult
    , viewSelect
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Time
import Types exposing (Msg(..))



-- VIEW HELPERS


viewFirestoreError : Maybe String -> Html Msg
viewFirestoreError maybeErr =
    case maybeErr of
        Nothing ->
            text ""

        Just err ->
            div
                [ attribute "style"
                    "background:#c0392b;color:#fff;padding:12px 20px;font-family:system-ui,sans-serif"
                ]
                [ text ("Erreur Firestore : " ++ err) ]


viewNav : String -> Html Msg
viewNav active =
    nav [ style "margin-bottom" "24px", style "display" "flex", style "gap" "8px" ]
        [ button [ onClick GoToTeamHome, navBtnStyle ] [ text "← Équipe" ]
        , button [ onClick GoToSort, navBtnActiveStyle (active == "sort") ] [ text "Tris" ]
        , button [ onClick GoToSearch, navBtnActiveStyle (active == "search") ] [ text "Recherches" ]
        , button [ onClick GoToGame, navBtnActiveStyle (active == "game") ] [ text "Jeu" ]
        , button [ onClick GoToStats, navBtnActiveStyle (active == "stats") ] [ text "Stats" ]
        ]


viewSelect : String -> List ( String, String ) -> String -> (String -> Msg) -> Html Msg
viewSelect labelText options selectedVal toMsg =
    div [ style "margin-bottom" "16px" ]
        [ label [ style "display" "block", style "margin-bottom" "4px" ] [ text labelText ]
        , select
            [ onInput toMsg
            , style "padding" "6px 10px"
            , style "font-size" "1rem"
            ]
            (List.map
                (\( val, lbl ) ->
                    option [ value val, selected (val == selectedVal) ] [ text lbl ]
                )
                options
            )
        ]


viewResult : Maybe Int -> (Int -> List ( String, String )) -> Html Msg
viewResult maybeResult toRows =
    case maybeResult of
        Nothing ->
            text ""

        Just count ->
            div
                [ style "background" "#f0f4f8"
                , style "border-radius" "8px"
                , style "padding" "16px"
                , style "margin-top" "16px"
                ]
                [ h3 [ style "margin-top" "0" ] [ text "Résultat" ]
                , dl
                    [ style "display" "grid"
                    , style "grid-template-columns" "auto 1fr"
                    , style "gap" "4px 16px"
                    ]
                    (toRows count
                        |> List.concatMap
                            (\( k, v ) ->
                                [ dt [ style "font-weight" "bold" ] [ text k ]
                                , dd [ style "margin" "0" ] [ text v ]
                                ]
                            )
                    )
                ]


viewError : Maybe String -> Html Msg
viewError maybeError =
    case maybeError of
        Nothing ->
            text ""

        Just err ->
            p [ style "color" "#c0392b" ] [ text err ]



-- EVENT HELPERS


onEnter : Msg -> Attribute Msg
onEnter msg =
    on "keydown"
        (Decode.field "key" Decode.string
            |> Decode.andThen
                (\key ->
                    if key == "Enter" then
                        Decode.succeed msg

                    else
                        Decode.fail "not enter"
                )
        )



-- FORMAT


formatNumber : Int -> String
formatNumber n =
    let
        s =
            String.fromInt (abs n)

        formatted =
            s
                |> String.foldr
                    (\c ( chars, i ) ->
                        if i > 0 && modBy 3 i == 0 then
                            ( c :: '\'' :: chars, i + 1 )

                        else
                            ( c :: chars, i + 1 )
                    )
                    ( [], 0 )
                |> Tuple.first
                |> String.fromList
    in
    if n < 0 then
        "-" ++ formatted

    else
        formatted


formatTimestamp : Time.Posix -> Time.Zone -> Time.Posix -> String
formatTimestamp now zone t =
    let
        diffSec =
            (Time.posixToMillis now - Time.posixToMillis t) // 1000
    in
    if diffSec < 60 then
        "à l'instant"

    else if diffSec < 3600 then
        String.padLeft 2 '0' (String.fromInt (Time.toHour zone t))
            ++ ":"
            ++ String.padLeft 2 '0' (String.fromInt (Time.toMinute zone t))

    else
        String.fromInt (Time.toDay zone t)
            ++ " "
            ++ monthName (Time.toMonth zone t)
            ++ " "
            ++ String.fromInt (Time.toYear zone t)


monthName : Time.Month -> String
monthName month =
    case month of
        Time.Jan ->
            "jan"

        Time.Feb ->
            "fév"

        Time.Mar ->
            "mars"

        Time.Apr ->
            "avr"

        Time.May ->
            "mai"

        Time.Jun ->
            "juin"

        Time.Jul ->
            "juil"

        Time.Aug ->
            "août"

        Time.Sep ->
            "sep"

        Time.Oct ->
            "oct"

        Time.Nov ->
            "nov"

        Time.Dec ->
            "déc"



-- STYLES


pageStyle : Attribute msg
pageStyle =
    attribute "style"
        "max-width:560px;margin:40px auto;padding:0 20px;font-family:system-ui,sans-serif;line-height:1.5"


btnStyle : Attribute msg
btnStyle =
    attribute "style"
        "padding:8px 18px;font-size:1rem;cursor:pointer;border:1px solid #aaa;border-radius:4px;background:#fff"


navBtnStyle : Attribute msg
navBtnStyle =
    attribute "style"
        "padding:6px 14px;font-size:0.9rem;cursor:pointer;border:1px solid #aaa;border-radius:4px;background:#fff"


navBtnActiveStyle : Bool -> Attribute msg
navBtnActiveStyle isActive =
    if isActive then
        attribute "style"
            "padding:6px 14px;font-size:0.9rem;cursor:pointer;border:1px solid #333;border-radius:4px;background:#333;color:#fff;font-weight:bold"

    else
        navBtnStyle


inputStyle : Attribute msg
inputStyle =
    attribute "style"
        "display:block;width:100%;box-sizing:border-box;padding:8px;font-size:1rem;border:1px solid #aaa;border-radius:4px;margin-bottom:8px"


subtleStyle : Attribute msg
subtleStyle =
    style "color" "#666"


thStyle : Attribute msg
thStyle =
    attribute "style"
        "padding:8px;border-bottom:2px solid #ccc"


tdStyle : Attribute msg
tdStyle =
    attribute "style"
        "padding:6px 8px;border-bottom:1px solid #eee"


deleteBtnStyle : Attribute msg
deleteBtnStyle =
    attribute "style"
        "padding:2px 7px;font-size:1rem;cursor:pointer;border:1px solid #e15759;border-radius:4px;background:#fff;color:#e15759;line-height:1"
