from typing import Any, Callable

SortAlgorithm = Callable[[list[Any]], int]


##########################
# Merge sort from
# https://gist.github.com/dishaumarwani/b6d5f4a1b2f741d5bee8d0f69263c48f


def merge(arr, lo, mo, ro):
    """Merge two sorted subarrays arr[lo..mo] and arr[mo+1..ro].
    Returns the number of inversions between the two halves."""
    # No need of merging if subarray form a sorted array after joining
    if arr[mo] <= arr[mo + 1]:
        return 0

    L = arr[lo : mo + 1]
    R = arr[mo + 1 : ro + 1]

    # Merge the temp arrays back into arr[lo..ro]

    i = 0  # Initial index of first subarray
    j = 0  # Initial index of second subarray
    k = lo  # Initial index of merged subarray

    len_l = mo + 1 - lo
    len_r = ro - mo

    cnt = 0
    while i < len_l and j < len_r:
        if L[i] <= R[j]:
            arr[k] = L[i]
            i += 1
        else:
            arr[k] = R[j]
            j += 1
            cnt += len_l - i
        k += 1

    arr[k : k + len_l - i] = L[i:]

    return cnt


def merge_sort(arr: list[Any], lo=None, ro=None) -> int:
    """Sort arr[lo..ro] in place using merge sort. Returns the number of inversions."""
    if lo is None:
        lo = 0
    if ro is None:
        ro = len(arr) - 1

    x = 0
    if lo < ro:
        mo = (lo + ro) // 2
        x = merge_sort(arr, lo, mo)
        x += merge_sort(arr, mo + 1, ro)
        x += merge(arr, lo, mo, ro)
    return x


##########################
# Insertion sort from
# https://stackoverflow.com/questions/56180411/how-to-count-the-amount-of-swaps-made-in-insertion-sort


def insertion_sort(array: list[Any]) -> int:
    """Sort array in place using insertion sort. Returns the number of comparisons."""
    swapsmade = 0
    checksmade = 0
    for f in range(len(array)):
        value = array[f]
        valueindex = f
        checksmade += 1
        # moving the value
        while valueindex > 0 and value < array[valueindex - 1]:
            array[valueindex] = array[valueindex - 1]
            valueindex -= 1
            checksmade += 1
            swapsmade += 1
        array[valueindex] = value
    return checksmade


registry: dict[str, SortAlgorithm] = {
    "Tri par fusion": merge_sort,
    "Tri par insertion": insertion_sort,
}
