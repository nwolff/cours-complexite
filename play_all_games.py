#!/usr/bin/env python

import random

import algorithms.search
import algorithms.sort
import stats

ROUNDS = 10


def int_exp_range(start, end, mul):
    while start < end:
        yield int(start)
        start *= mul


for algorithm_name, algorithm in algorithms.search.registry.items():
    for n in int_exp_range(1_000, 1_100_000, 1.3):
        for round in range(ROUNDS):
            print(f"\t {algorithm_name}, max: {n:_} (round {round})")
            game = algorithms.search.Game(n)
            algorithm(max=n, oracle=game.guess)
            stat = stats.Stat(
                team="autobot", algorithm=algorithm_name, n=n, result=game.guesses
            )
            stats.insert_stat(stat)

for algorithm_name, sort_algorithm in algorithms.sort.registry.items():
    for n in int_exp_range(1_000, 1_100_000, 1.3):
        for round in range(ROUNDS):
            print(f"\t {algorithm_name}, taille: {n:_} (round {round})")
            lst = list(range(n))
            random.shuffle(lst)
            checks = sort_algorithm(lst)
            stat = stats.Stat(
                team="autobot", algorithm=algorithm_name, n=n, result=checks
            )
            stats.insert_stat(stat)
