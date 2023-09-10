#!/usr/bin/env python

from itertools import groupby
from operator import attrgetter

import xlsxwriter

import stats

workbook = xlsxwriter.Workbook("stats.xlsx")


def dump_to_sheet(sheet_name, data):
    worksheet = workbook.add_worksheet(sheet_name)
    for col, header in enumerate(["equipe", "algorithme", "n", "résultat"]):
        worksheet.write(0, col, header)
        for i, stat in enumerate(data):
            worksheet.write(i + 1, 0, stat.team)
            worksheet.write(i + 1, 1, stat.algorithm)
            worksheet.write(i + 1, 2, stat.n)
            worksheet.write(i + 1, 3, stat.result)


all_stats = stats.all_stats()
dump_to_sheet("Tout", all_stats)


def key_func(stat):
    return (stat.team, stat.algorithm, stat.n)


sorted_stats = sorted(all_stats, key=key_func)
max_stats = []
for key, group in groupby(sorted_stats, key=key_func):
    sorted_group = sorted(group, key=attrgetter("result"))
    max_stats.append(sorted_group[-1])

dump_to_sheet("Max", max_stats)

workbook.close()
