module Sort exposing (Algorithm(..), algorithmName, allAlgorithms, run, sortSizes)


type Algorithm
    = QuickSort
    | InsertionSort
    | MergeSort


algorithmName : Algorithm -> String
algorithmName algo =
    case algo of
        QuickSort ->
            "Tri rapide"

        InsertionSort ->
            "Tri par insertion"

        MergeSort ->
            "Tri fusion"


allAlgorithms : List Algorithm
allAlgorithms =
    [ QuickSort, MergeSort, InsertionSort ]



-- Reasonable sizes for client-side execution.
-- InsertionSort is O(n²) so we cap at 10_000 to avoid freezing the browser.


sortSizes : List Int
sortSizes =
    [ 10, 100, 500, 1000, 2000, 5000, 10000 ]


run : Algorithm -> List Int -> Int
run algo lst =
    case algo of
        QuickSort ->
            quicksort lst

        InsertionSort ->
            insertionSort lst

        MergeSort ->
            mergeSort lst



-- QUICKSORT
-- Functional pivot-first quicksort.
-- Comparisons = List.length of each partition's tail, summed recursively.
-- Picks first element as pivot → O(n²) on sorted input, O(n log n) on random.
-- We always sort a freshly shuffled list, so worst-case is very unlikely.


quicksort : List Int -> Int
quicksort lst =
    case lst of
        [] ->
            0

        _ :: [] ->
            0

        pivot :: rest ->
            let
                ( smaller, larger ) =
                    List.partition (\x -> x < pivot) rest

                comparisons =
                    List.length rest
            in
            comparisons + quicksort smaller + quicksort larger



-- INSERTION SORT
-- Tail-recursive implementation to avoid stack overflows at n=10_000.
-- Counts each element comparison (both successful and failed).


insertionSort : List Int -> Int
insertionSort xs =
    List.foldl insertSorted ( [], 0 ) xs
        |> Tuple.second


insertSorted : Int -> ( List Int, Int ) -> ( List Int, Int )
insertSorted x ( sorted, total ) =
    let
        ( newSorted, comparisons ) =
            insertInto x sorted
    in
    ( newSorted, total + comparisons )



-- Tail-recursive: accumulates the "before" portion in reverse, then
-- reassembles with reverseAppend.


insertInto : Int -> List Int -> ( List Int, Int )
insertInto x sorted =
    insertIntoAcc x sorted [] 0


insertIntoAcc : Int -> List Int -> List Int -> Int -> ( List Int, Int )
insertIntoAcc x remaining acc count =
    case remaining of
        [] ->
            ( reverseAppend acc [ x ], count )

        head :: tail ->
            if x <= head then
                ( reverseAppend acc (x :: remaining), count + 1 )

            else
                insertIntoAcc x tail (head :: acc) (count + 1)



-- MERGE SORT
-- Classic top-down merge sort.
-- Comparisons = each element comparison during the merge step.


mergeSort : List Int -> Int
mergeSort lst =
    case lst of
        [] ->
            0

        _ :: [] ->
            0

        _ ->
            let
                mid =
                    List.length lst // 2

                left =
                    List.take mid lst

                right =
                    List.drop mid lst
            in
            mergeSort left + mergeSort right + merge left right


merge : List Int -> List Int -> Int
merge left right =
    case ( left, right ) of
        ( [], _ ) ->
            0

        ( _, [] ) ->
            0

        ( l :: ls, r :: rs ) ->
            if l <= r then
                1 + merge ls right

            else
                1 + merge left rs


reverseAppend : List a -> List a -> List a
reverseAppend reversed rest =
    case reversed of
        [] ->
            rest

        h :: t ->
            reverseAppend t (h :: rest)
