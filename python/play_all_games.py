import random

import search_algorithms
import sort_algorithms
import stats

ROUNDS = 10


def int_exp_range(start, end, mul):
    while start < end:
        yield int(start)
        start *= mul


def run_search_benchmarks(n, round_num, stat_list):
    """Executes all registered search algorithms for a given size and round."""
    for algorithm_name, algorithm in search_algorithms.registry.items():
        print(f"\t {algorithm_name}, max: {n:_} (round {round_num})")
        game = search_algorithms.Game(n)
        algorithm(max=n, oracle=game.guess)
        stat_list.append(
            stats.Stat(
                team="autobot", algorithm=algorithm_name, n=n, result=game.guesses
            )
        )


def run_sort_benchmarks(n, round_num, stat_list):
    """Executes all registered sort algorithms for a given size and round."""
    for algorithm_name, sort_algorithm in sort_algorithms.registry.items():
        print(f"\t {algorithm_name}, taille: {n:_} (round {round_num})")
        lst = list(range(n))
        random.shuffle(lst)
        checks = sort_algorithm(lst)
        stat_list.append(
            stats.Stat(team="autobot", algorithm=algorithm_name, n=n, result=checks)
        )


if __name__ == "__main__":
    sizes = list(int_exp_range(1_000, 1_100_000, 1.3))
    pending = []

    for round_idx in range(ROUNDS):
        for n in sizes:
            run_search_benchmarks(n, round_idx, pending)
            run_sort_benchmarks(n, round_idx, pending)
            if len(pending) >= 20:
                print(f"Flushing {len(pending)} stats…")
                stats.insert_stats_batch(pending)
                pending.clear()

    if pending:
        print(f"Flushing {len(pending)} remaining stats…")
        stats.insert_stats_batch(pending)
