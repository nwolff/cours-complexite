#!/usr/bin/env python

import random
from enum import Enum

import inquirer  # type: ignore

import algorithms.search
import algorithms.sort
import stats


class StatFilterEnum(Enum):
    TEAM = "TEAM"
    ALGORITHM = "ALGORITHM"
    ALL = "ALL"


def stats_command():
    stats_kind = inquirer.list_input(
        message="Quelles stats ?",
        choices=[
            ("Stats par équipe", StatFilterEnum.TEAM),
            ("Stats par algorithme", StatFilterEnum.ALGORITHM),
            ("Toutes les stats", StatFilterEnum.ALL),
        ],
    )
    filter = {}
    if stats_kind == StatFilterEnum.TEAM:
        all_teams = stats.all_teams()
        team = inquirer.list_input(message="Quelle équipe ?", choices=all_teams)
        filter["team"] = team
    elif stats_kind == StatFilterEnum.ALGORITHM:
        all_algorithms = stats.all_algorithms()
        algorithm = inquirer.list_input(
            message="Quel algorithme ?", choices=all_algorithms
        )
        filter["algorithm"] = algorithm
    print(stats.all_stats(**filter))


def start_game_command(team):
    questions = [
        inquirer.Text(
            "max",
            message="Borne supérieure (minimum 100)",
            default=100,
            validate=lambda _, c: int(c) >= 100,
        ),
    ]
    answers = inquirer.prompt(questions)
    max = int(answers["max"])
    game = algorithms.search.Game(max)
    guessing_loop(game)
    stat = stats.Stat(team=team, algorithm="Humain", n=max, result=game.guesses)
    stats.insert_stat(stat)


text_for_outcome = {
    -1: "Plus petit",
    0: "Bingo!",
    1: "Plus grand",
}


def guessing_loop(game: algorithms.search.Game):
    while True:
        answer = inquirer.text(
            message=f"Essai {game.guesses}. Quel nombre proposez-vous ?"
        )
        try:
            n = int(answer)
        except ValueError:
            print("'{answer}' n'est pas un nombre")
            continue
        outcome = game.guess(n)
        print(text_for_outcome[outcome])
        if outcome == 0:
            break


CHOICES_OF_MAX = [
    10,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    1_000,
    1_500,
    2_000,
    3_000,
    5_000,
    10_000,
    50_000,
    100_000,
    500_000,
    1_000_000,
]


def run_search_algorithm_command(team):
    algorithm_name = inquirer.list_input(
        message="Algorithme ?", choices=algorithms.search.registry.keys()
    )
    max = inquirer.list_input(
        message="Borne supérieure ?",
        choices=[(f"{c:_}", c) for c in CHOICES_OF_MAX],
    )
    algorithm = algorithms.search.registry[algorithm_name]
    game = algorithm.search.Game(max)

    def oracle(n):
        outcome = game.guess(n)
        print(f"Essai {game.guesses:_}.\t Proposition {n:_}")
        return outcome

    algorithm(max=max, oracle=oracle)
    print(
        f"\nBorne supérieure: {game.max:_}. Secret {game.secret:_}. Trouvé en {game.guesses:_} essais.\n"
    )
    stat = stats.Stat(team=team, algorithm=algorithm_name, n=max, result=game.guesses)
    stats.insert_stat(stat)


def run_sort_algorithm_command(team):
    algorithm_name = inquirer.list_input(
        message="Algorithme ?", choices=algorithms.sort.registry.keys()
    )
    list_size = inquirer.list_input(
        message="Taille de la liste à trier ?",
        choices=[(f"{c:_}", c) for c in CHOICES_OF_MAX],
    )
    algorithm = algorithms.sort.registry[algorithm_name]

    lst = list(range(list_size))
    random.shuffle(lst)
    swaps = algorithm(lst)
    print(
        f"\nTri d'une liste de taille: {list_size:_} avec {algorithm_name} a demandé {swaps:_} échanges.\n"
    )
    stat = stats.Stat(team=team, algorithm=algorithm_name, n=list_size, result=swaps)
    stats.insert_stat(stat)


def main():
    team = inquirer.text(message="Votre nom d'équipe")

    while True:
        print()
        operation = inquirer.list_input(
            message="Que voulez-vous faire",
            choices=[
                ("Nouvelle partie", "START_GAME"),
                ("Faire jouer un algorithme de recherche", "RUN_SEARCH_ALGORITHM"),
                ("Exécuter un algorithme de tri", "RUN_SORT_ALGORITHM"),
                ("Voir les statistiques", "SEE_STATS"),
                ("Quitter", "QUIT"),
            ],
        )

        if operation == "START_GAME":
            start_game_command(team)
        elif operation == "RUN_SEARCH_ALGORITHM":
            run_search_algorithm_command(team)
        elif operation == "RUN_SORT_ALGORITHM":
            run_sort_algorithm_command(team)
        elif operation == "SEE_STATS":
            stats_command()
        elif operation == "QUIT":
            break
        else:
            print("Unknown operation", operation)


if __name__ == "__main__":
    main()
