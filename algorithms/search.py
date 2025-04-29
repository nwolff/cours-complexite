import random
from dataclasses import dataclass, field
from typing import Callable


@dataclass
class Game:
    max: int
    guesses = 0
    secret: int = field(init=False)

    def __post_init__(self):
        self.secret = random.randint(1, self.max)

    def guess(self, n: int) -> int:
        self.guesses += 1
        return (self.secret > n) - (self.secret < n)


Oracle = Callable[[int], int]


def sequential(max: int, oracle: Oracle):
    for n in range(1, max):
        outcome = oracle(n)
        if outcome == 0:
            return


def shuffled_sequence(max: int, oracle: Oracle):
    elements = list(range(1, max))
    random.shuffle(elements)
    for n in elements:
        outcome = oracle(n)
        if outcome == 0:
            return


def completely_random(max: int, oracle: Oracle):
    while True:
        guess = random.randint(0, max)
        outcome = oracle(guess)
        if outcome == 0:
            return


def dichotomy(max: int, oracle: Oracle):
    lower = 1
    upper = max
    while True:
        n = lower + (upper - lower) // 2
        outcome = oracle(n)
        if outcome == 0:
            return
        elif outcome == -1:
            upper = n
        else:
            lower = n


registry = {
    "Recherche dichotomique": dichotomy,
    "Recherche séquentielle": sequential,
    "Recherche Séquentielle mélangée": shuffled_sequence,
    "Recherche aléatoire": completely_random,
}
