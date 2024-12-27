module Chart exposing (viewChart)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Svg
import Svg.Attributes as SvgA
import Types exposing (Msg(..), Stat)


viewChart : Bool -> List Stat -> Html Msg
viewChart logScale stats =
    let
        validStats =
            List.filter (\s -> s.n > 0 && s.result > 0) stats
    in
    if List.isEmpty validStats then
        text ""

    else
        let
            mL =
                55

            mR =
                30

            mT =
                14

            mB =
                38

            pW =
                435

            pH =
                pW

            -- square plot area: equal axes means O(n) is literally 45°
            svgW =
                mL + pW + mR

            svgH =
                mT + pH + mB

            ns =
                List.map (.n >> toFloat) validStats

            rs =
                List.map (.result >> toFloat) validStats

            xMin =
                List.minimum ns |> Maybe.withDefault 10

            xMax =
                List.maximum ns |> Maybe.withDefault 100000

            yMin =
                List.minimum rs |> Maybe.withDefault 1

            yMax =
                List.maximum rs |> Maybe.withDefault 1000000

            -- Log scale: both axes share the same domain so slopes are comparable
            logDomLo =
                Basics.min (xMin / 2) (yMin / 2)

            logDomHi =
                Basics.max (xMax * 2) (yMax * 2)

            xDomLo =
                if logScale then
                    logDomLo

                else
                    0

            xDomHi =
                if logScale then
                    logDomHi

                else
                    xMax * 1.1

            yDomLo =
                if logScale then
                    logDomLo

                else
                    0

            yDomHi =
                if logScale then
                    logDomHi

                else
                    yMax * 1.1

            toX v =
                if logScale then
                    logMap xDomLo xDomHi 0 (toFloat pW) v

                else
                    linearMap xDomLo xDomHi 0 (toFloat pW) v

            toY v =
                if logScale then
                    logMap yDomLo yDomHi (toFloat pH) 0 v

                else
                    linearMap yDomLo yDomHi (toFloat pH) 0 v

            sharedTicks =
                powersOf10InRange logDomLo logDomHi

            xTicks =
                if logScale then
                    sharedTicks

                else
                    linearTicks xDomLo xDomHi

            yTicks =
                if logScale then
                    sharedTicks

                else
                    linearTicks yDomLo yDomHi

            algos =
                uniqueAlgos validStats
        in
        div [ style "margin-top" "20px" ]
            [ div
                [ style "display" "flex"
                , style "align-items" "center"
                , style "gap" "6px"
                , style "margin-bottom" "6px"
                , style "padding-left" (String.fromInt mL ++ "px")
                ]
                [ input
                    [ type_ "checkbox"
                    , checked logScale
                    , onClick ToggleChartScale
                    , style "cursor" "pointer"
                    ]
                    []
                , span
                    [ onClick ToggleChartScale
                    , style "font-size" "0.85rem"
                    , style "color" "#555"
                    , style "cursor" "pointer"
                    , style "user-select" "none"
                    ]
                    [ text "Échelle logarithmique" ]
                ]
            , Svg.svg
                [ SvgA.width (String.fromInt svgW)
                , SvgA.height (String.fromInt svgH)
                , SvgA.style "display:block;max-width:100%;overflow:visible"
                ]
                [ Svg.g
                    [ SvgA.transform
                        ("translate(" ++ String.fromInt mL ++ "," ++ String.fromInt mT ++ ")")
                    ]
                    (List.concat
                        [ viewRefCurves logScale toX toY xDomLo xDomHi yDomLo yDomHi pW
                        , List.map (viewYTick toY pW) yTicks
                        , List.map (viewXTick toX pH) xTicks
                        , [ Svg.line
                                [ SvgA.x1 "0"
                                , SvgA.y1 (String.fromInt pH)
                                , SvgA.x2 (String.fromInt pW)
                                , SvgA.y2 (String.fromInt pH)
                                , SvgA.stroke "#ccc"
                                , SvgA.strokeWidth "1"
                                ]
                                []
                          , Svg.line
                                [ SvgA.x1 "0"
                                , SvgA.y1 "0"
                                , SvgA.x2 "0"
                                , SvgA.y2 (String.fromInt pH)
                                , SvgA.stroke "#ccc"
                                , SvgA.strokeWidth "1"
                                ]
                                []
                          ]
                        , List.map (viewDot toX toY) validStats
                        ]
                    )
                ]
            , viewLegend algos
            ]



-- Reference curves for common complexity classes (log scale only).
-- Each curve is normalized to pass through the geometric centre of the domain
-- so all four cross at the same point, making slope comparison easy.


viewRefCurves : Bool -> (Float -> Float) -> (Float -> Float) -> Float -> Float -> Float -> Float -> Int -> List (Svg.Svg msg)
viewRefCurves logScale toX toY xDomLo xDomHi yDomLo yDomHi pW =
    let
        -- Normalise each curve to pass through the centre of the visible area
        xNorm =
            if logScale then
                sqrt (xDomLo * xDomHi)

            else
                xDomHi / 2

        yNorm =
            if logScale then
                sqrt (yDomLo * yDomHi)

            else
                yDomHi / 2

        xValues =
            List.range 0 200
                |> List.map
                    (\i ->
                        let
                            t =
                                toFloat i / 200
                        in
                        if logScale then
                            xDomLo * (xDomHi / xDomLo) ^ t

                        else
                            xDomLo + (xDomHi - xDomLo) * t
                    )

        curves =
            [ ( "log n", \x -> logBase 2 x )
            , ( "n", \x -> x )
            , ( "n·log n", \x -> x * logBase 2 x )
            , ( "n²", \x -> x ^ 2 )
            ]
    in
    List.filterMap
        (\( label, f ) ->
            let
                c =
                    yNorm / f xNorm

                pts =
                    List.filterMap
                        (\x ->
                            let
                                y =
                                    c * f x
                            in
                            if y >= yDomLo && y <= yDomHi then
                                Just ( toX x, toY y )

                            else
                                Nothing
                        )
                        xValues
            in
            if List.isEmpty pts then
                Nothing

            else
                let
                    pointsStr =
                        pts
                            |> List.map (\( px, py ) -> String.fromFloat px ++ "," ++ String.fromFloat py)
                            |> String.join " "

                    ( lastX, lastY ) =
                        pts |> List.reverse |> List.head |> Maybe.withDefault ( 0, 0 )

                    atRightEdge =
                        lastX > toFloat pW * 0.95

                    atTop =
                        lastY < 8

                    ( textX, textY, textAnchor ) =
                        if atTop && atRightEdge then
                            ( lastX - 3, 14, "end" )

                        else if atTop then
                            ( lastX + 3, 14, "start" )

                        else
                            ( lastX - 3, lastY - 4, "end" )
                in
                Just
                    (Svg.g []
                        [ Svg.polyline
                            [ SvgA.points pointsStr
                            , SvgA.fill "none"
                            , SvgA.stroke "#d8d8d8"
                            , SvgA.strokeWidth "1"
                            , SvgA.strokeDasharray "4 3"
                            ]
                            []
                        , Svg.text_
                            [ SvgA.x (String.fromFloat textX)
                            , SvgA.y (String.fromFloat textY)
                            , SvgA.fontSize "10"
                            , SvgA.fill "#bbb"
                            , SvgA.textAnchor textAnchor
                            ]
                            [ text label ]
                        ]
                    )
        )
        curves


logMap : Float -> Float -> Float -> Float -> Float -> Float
logMap lo hi rLo rHi v =
    let
        t =
            (logBase 10 v - logBase 10 lo) / (logBase 10 hi - logBase 10 lo)
    in
    rLo + t * (rHi - rLo)


linearMap : Float -> Float -> Float -> Float -> Float -> Float
linearMap lo hi rLo rHi v =
    let
        t =
            (v - lo) / (hi - lo)
    in
    rLo + t * (rHi - rLo)


powersOf10InRange : Float -> Float -> List Float
powersOf10InRange lo hi =
    let
        startExp =
            floor (logBase 10 lo)

        endExp =
            ceiling (logBase 10 hi)
    in
    List.range startExp endExp
        |> List.map (\e -> 10.0 ^ toFloat e)
        |> List.filter (\v -> v >= lo && v <= hi * 1.001)


linearTicks : Float -> Float -> List Float
linearTicks lo hi =
    let
        rawStep =
            (hi - lo) / 5

        exp =
            toFloat (floor (logBase 10 rawStep))

        magnitude =
            10 ^ exp

        niceStep =
            if rawStep / magnitude <= 1 then
                magnitude

            else if rawStep / magnitude <= 2 then
                2 * magnitude

            else if rawStep / magnitude <= 5 then
                5 * magnitude

            else
                10 * magnitude

        startI =
            ceiling (lo / niceStep)

        endI =
            floor (hi / niceStep)
    in
    List.range startI endI
        |> List.map (\i -> toFloat i * niceStep)
        |> List.filter (\v -> v >= lo && v <= hi * 1.001)


viewXTick : (Float -> Float) -> Int -> Float -> Svg.Svg msg
viewXTick toX pH v =
    let
        x =
            String.fromFloat (toX v)
    in
    Svg.g []
        [ Svg.line
            [ SvgA.x1 x
            , SvgA.y1 "0"
            , SvgA.x2 x
            , SvgA.y2 (String.fromInt pH)
            , SvgA.stroke "#eee"
            , SvgA.strokeWidth "1"
            ]
            []
        , Svg.line
            [ SvgA.x1 x
            , SvgA.y1 (String.fromInt pH)
            , SvgA.x2 x
            , SvgA.y2 (String.fromInt (pH + 4))
            , SvgA.stroke "#aaa"
            , SvgA.strokeWidth "1"
            ]
            []
        , Svg.text_
            [ SvgA.x x
            , SvgA.y (String.fromInt (pH + 16))
            , SvgA.textAnchor "middle"
            , SvgA.fontSize "11"
            , SvgA.fill "#888"
            ]
            [ text (compactInt (round v)) ]
        ]


viewYTick : (Float -> Float) -> Int -> Float -> Svg.Svg msg
viewYTick toY pW v =
    let
        y =
            String.fromFloat (toY v)
    in
    Svg.g []
        [ Svg.line
            [ SvgA.x1 "0"
            , SvgA.y1 y
            , SvgA.x2 (String.fromInt pW)
            , SvgA.y2 y
            , SvgA.stroke "#eee"
            , SvgA.strokeWidth "1"
            ]
            []
        , Svg.line
            [ SvgA.x1 "-4"
            , SvgA.y1 y
            , SvgA.x2 "0"
            , SvgA.y2 y
            , SvgA.stroke "#aaa"
            , SvgA.strokeWidth "1"
            ]
            []
        , Svg.text_
            [ SvgA.x "-8"
            , SvgA.y (String.fromFloat (toY v + 4))
            , SvgA.textAnchor "end"
            , SvgA.fontSize "11"
            , SvgA.fill "#888"
            ]
            [ text (compactInt (round v)) ]
        ]


viewDot : (Float -> Float) -> (Float -> Float) -> Stat -> Svg.Svg msg
viewDot toX toY stat =
    Svg.circle
        [ SvgA.cx (String.fromFloat (toX (toFloat stat.n)))
        , SvgA.cy (String.fromFloat (toY (toFloat stat.result)))
        , SvgA.r "5"
        , SvgA.fill (algoColor stat.algorithm)
        , SvgA.fillOpacity "0.75"
        ]
        []


viewLegend : List String -> Html msg
viewLegend algos =
    if List.isEmpty algos then
        text ""

    else
        div
            [ style "display" "flex"
            , style "flex-wrap" "wrap"
            , style "gap" "6px 20px"
            , style "padding-left" "55px"
            , style "margin-top" "6px"
            ]
            (List.map
                (\algo ->
                    span
                        [ style "display" "inline-flex"
                        , style "align-items" "center"
                        , style "gap" "5px"
                        , style "font-size" "0.82rem"
                        , style "color" "#555"
                        ]
                        [ span
                            [ style "display" "inline-block"
                            , style "width" "10px"
                            , style "height" "10px"
                            , style "border-radius" "50%"
                            , style "background" (algoColor algo)
                            , style "flex-shrink" "0"
                            ]
                            []
                        , text algo
                        ]
                )
                algos
            )


algoColor : String -> String
algoColor name =
    case name of
        "Tri rapide" ->
            "#4e79a7"

        "Tri fusion" ->
            "#9c755f"

        "Tri par insertion" ->
            "#f28e2b"

        "Recherche dichotomique" ->
            "#59a14f"

        "Recherche séquentielle" ->
            "#e15759"

        "Recherche séquentielle mélangée" ->
            "#76b7b2"

        "Recherche aléatoire" ->
            "#b07aa1"

        "Humain" ->
            "#ff9da7"

        _ ->
            "#888"


compactInt : Int -> String
compactInt n =
    if n >= 1000000 then
        String.fromInt (n // 1000000) ++ "M"

    else if n >= 1000 then
        String.fromInt (n // 1000) ++ "k"

    else
        String.fromInt n


uniqueAlgos : List Stat -> List String
uniqueAlgos stats =
    List.foldl
        (\s acc ->
            if List.member s.algorithm acc then
                acc

            else
                acc ++ [ s.algorithm ]
        )
        []
        stats
