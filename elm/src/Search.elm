module Search exposing
    ( Algorithm(..)
    , Setup(..)
    , algorithmName
    , allAlgorithms
    , run
    , searchSizes
    , setupGenerator
    )

import Random


type Algorithm
    = Dichotomy
    | Sequential
    | ShuffledSequential
    | CompletelyRandom



-- Setup carries whatever randomness each algorithm needs before it can run.


type Setup
    = DirectSetup Int
      -- secret only; used by Dichotomy and Sequential
    | ShuffledSetup (List Int) Int
      -- a random permutation of [1..max] + the secret
    | RandomSetup Int Random.Seed



-- secret + an independent seed for the random-guess loop


algorithmName : Algorithm -> String
algorithmName algo =
    case algo of
        Dichotomy ->
            "Recherche dichotomique"

        Sequential ->
            "Recherche séquentielle"

        ShuffledSequential ->
            "Recherche séquentielle mélangée"

        CompletelyRandom ->
            "Recherche aléatoire"


allAlgorithms : List Algorithm
allAlgorithms =
    [ Dichotomy, Sequential, ShuffledSequential, CompletelyRandom ]


searchSizes : List Int
searchSizes =
    [ 10, 100, 500, 1000, 5000, 10000, 50000, 100000 ]



-- Produce the right Setup variant for the chosen algorithm and range size.


setupGenerator : Algorithm -> Int -> Random.Generator Setup
setupGenerator algo max =
    case algo of
        Dichotomy ->
            Random.map DirectSetup (Random.int 1 max)

        Sequential ->
            Random.map DirectSetup (Random.int 1 max)

        ShuffledSequential ->
            Random.map2 ShuffledSetup
                (shuffleGenerator max)
                (Random.int 1 max)

        CompletelyRandom ->
            Random.map2 RandomSetup
                (Random.int 1 max)
                Random.independentSeed



-- Shuffle [1..max] by pairing each element with a random float, then sorting.


shuffleGenerator : Int -> Random.Generator (List Int)
shuffleGenerator max =
    Random.list max (Random.float 0 1)
        |> Random.map
            (\floats ->
                List.range 1 max
                    |> List.map2 Tuple.pair floats
                    |> List.sortBy Tuple.first
                    |> List.map Tuple.second
            )


run : Algorithm -> Int -> Setup -> Int
run algo max setup =
    case ( algo, setup ) of
        ( Dichotomy, DirectSetup secret ) ->
            dichotomy max secret

        ( Sequential, DirectSetup secret ) ->
            sequential secret

        ( ShuffledSequential, ShuffledSetup shuffled secret ) ->
            shuffledSequential shuffled secret

        ( CompletelyRandom, RandomSetup secret seed ) ->
            completelyRandom max secret seed
                |> Tuple.first

        -- Impossible combos; the generator always produces the right variant.
        _ ->
            0



-- DICHOTOMY (binary search)
-- Tail-recursive; depth is at most ceil(log₂ max).


dichotomy : Int -> Int -> Int
dichotomy max secret =
    binarySearch 1 max secret 0


binarySearch : Int -> Int -> Int -> Int -> Int
binarySearch lower upper secret guesses =
    let
        mid =
            lower + (upper - lower) // 2
    in
    if mid == secret then
        guesses + 1

    else if mid > secret then
        binarySearch lower (mid - 1) secret (guesses + 1)

    else
        binarySearch (mid + 1) upper secret (guesses + 1)



-- SEQUENTIAL
-- Searches 1, 2, 3, … in order.  Finds `secret` after exactly `secret` guesses.


sequential : Int -> Int
sequential secret =
    secret



-- SHUFFLED SEQUENTIAL
-- Scans a random permutation of [1..max] until the secret is found.


shuffledSequential : List Int -> Int -> Int
shuffledSequential shuffled secret =
    shuffled
        |> List.foldl
            (\x acc ->
                case acc of
                    ( True, n ) ->
                        ( True, n )

                    ( False, n ) ->
                        if x == secret then
                            ( True, n + 1 )

                        else
                            ( False, n + 1 )
            )
            ( False, 0 )
        |> Tuple.second



-- COMPLETELY RANDOM (with replacement)
-- Draws uniformly from [1..max] until the secret is hit.
-- Tail-recursive → compiled to a JS while-loop (no stack overflow).
-- Expected guesses = max; worst case is unbounded but converges quickly in practice.


completelyRandom : Int -> Int -> Random.Seed -> ( Int, Random.Seed )
completelyRandom max secret seed =
    randomLoop max secret seed 0


randomLoop : Int -> Int -> Random.Seed -> Int -> ( Int, Random.Seed )
randomLoop max secret seed guesses =
    let
        ( guess, newSeed ) =
            Random.step (Random.int 1 max) seed
    in
    if guess == secret then
        ( guesses + 1, newSeed )

    else
        randomLoop max secret newSeed (guesses + 1)
