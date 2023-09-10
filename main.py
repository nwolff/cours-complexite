#!/usr/bin/env python

import random
from io import BytesIO

from flask import Flask, redirect, render_template, request, send_file, url_for

import algorithms.search
import algorithms.sort
import stats

app = Flask(__name__)
app.config["SEND_FILE_MAX_AGE_DEFAULT"] = 600

MIN_TEAM_CHARS = 3

CHOICES_OF_N = [
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


@app.template_filter("num")
def num_filter(n):
    return f"{n:_}"


@app.route("/", methods=["POST", "GET"])
def home():
    error = None
    if request.method == "POST":
        team = request.form["team"]
        if len(team) >= MIN_TEAM_CHARS:
            return redirect(url_for("team_home", team=team))
        else:
            error = f"Le nom d'équipe doit avoir au minimum {MIN_TEAM_CHARS} caractères"
    return render_template("home.html", error=error)


@app.route("/<team>")
def team_home(team):
    return render_template("team_home.html", team=team)


@app.route("/<team>/play")
def team_play(team):
    return render_template("team_play.html", team=team)


@app.route("/<team>/search", methods=["POST", "GET"])
def team_search(team):
    error = None
    stat = None
    algorithm_names = algorithms.search.registry.keys()

    if request.method == "POST":
        algorithm_name = request.form["algorithm_name"]
        max = int(request.form["max"])
        algorithm = algorithms.search.registry[algorithm_name]
        game = algorithms.search.Game(max)
        algorithm(max=max, oracle=game.guess)
        stat = stats.Stat(
            team="autobot", algorithm=algorithm_name, n=max, result=game.guesses
        )
        stats.insert_stat(stat)
    return render_template(
        "team_search.html",
        team=team,
        algorithm_names=algorithm_names,
        choices_of_max=CHOICES_OF_N,
        stat=stat,
        error=error,
    )


@app.route("/<team>/sort", methods=["POST", "GET"])
def team_sort(team):
    error = None
    stat = None
    algorithm_names = algorithms.sort.registry.keys()

    if request.method == "POST":
        algorithm_name = request.form["algorithm_name"]
        list_size = int(request.form["list_size"])
        algorithm = algorithms.sort.registry[algorithm_name]
        lst = list(range(list_size))
        random.shuffle(lst)
        swaps = algorithm(lst)
        print(
            f"\nTri d'une liste de taille: {list_size:_} avec {algorithm_name} a demandé {swaps:_} échanges.\n"
        )
        stat = stats.Stat(
            team=team, algorithm=algorithm_name, n=list_size, result=swaps
        )
        stats.insert_stat(stat)
    return render_template(
        "team_sort.html",
        team=team,
        algorithm_names=algorithm_names,
        choices_of_size=CHOICES_OF_N,
        stat=stat,
        error=error,
    )


import xlsxwriter


@app.route("/<team>/stats")
def team_stats(team):
    team_stats = stats.all_stats(team=team)
    excel_io = BytesIO()
    workbook = xlsxwriter.Workbook(excel_io)
    worksheet = workbook.add_worksheet("mes stats")
    for col, header in enumerate(["equipe", "algorithme", "n", "résultat"]):
        worksheet.write(0, col, header)
        for i, stat in enumerate(team_stats):
            worksheet.write(i + 1, 0, stat.team)
            worksheet.write(i + 1, 1, stat.algorithm)
            worksheet.write(i + 1, 2, stat.n)
            worksheet.write(i + 1, 3, stat.result)
    workbook.close()
    excel_io.seek(0)

    return send_file(
        excel_io,
        mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        download_name="my_stats.xlsx",
        as_attachment=True,
    )


if __name__ == "__main__":
    # Only when developing
    app.run(host="0.0.0.0", port=8080, debug=True)
