from typing import Any, Callable

SortAlgorithm = Callable[[list[Any]], int]


def partition(mylist, start, end, count):
    pos = start
    for i in range(start, end):
        count += 1
        if mylist[i] < mylist[end]:
            mylist[i], mylist[pos] = mylist[pos], mylist[i]
            pos += 1
    mylist[pos], mylist[end] = mylist[end], mylist[pos]
    return pos, count


def quicksort_helper(mylist, start, end, count):
    if start < end:
        pos, count = partition(mylist, start, end, count)
        count = quicksort_helper(mylist, start, pos - 1, count)
        count = quicksort_helper(mylist, pos + 1, end, count)
    return count


def quicksort(lst: list[Any]) -> int:
    return quicksort_helper(lst, 0, len(lst) - 1, 0)


##########################
# Merge sort from
# https://gist.github.com/dishaumarwani/b6d5f4a1b2f741d5bee8d0f69263c48f


def merge(arr, l, m, r):
    # No need of merging if subarray form a sorted array after joining
    if arr[m] <= arr[m + 1]:
        return 0

    L = arr[l : m + 1]
    R = arr[m + 1 : r + 1]

    # Merge the temp arrays back into arr[l..r]

    i = 0  # Initial index of first subarray
    j = 0  # Initial index of second subarray
    k = l  # Initial index of merged subarray

    len_l = m + 1 - l
    len_r = r - m

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


def merge_sort(arr: list[Any], l=None, r=None) -> int:
    if l is None:
        l = 0
    if r is None:
        r = len(arr) - 1

    x = 0
    if l < r:
        m = (l + r) // 2
        x = merge_sort(arr, l, m)
        x += merge_sort(arr, m + 1, r)
        x += merge(arr, l, m, r)
    return x


##########################
# Insertion sort from
# https://stackoverflow.com/questions/56180411/how-to-count-the-amount-of-swaps-made-in-insertion-sort


def insertion_sort(array: list[Any]) -> int:
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
    return swapsmade


registry: dict[str, SortAlgorithm] = {
    # "Tri par fusion": merge_sort,
    "Tri par insertion": insertion_sort,
    "Tri rapide": quicksort,
}
