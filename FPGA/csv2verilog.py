
import csv

with open('Controller Timing.csv', 'U') as csvfile:
    rows = [row for row in csv.reader(csvfile)]
    for row in rows[1:]:
        s = "7'd%03d: rom_data = 5'b%s%s%s%s%s;"
        row[0] = int(row[0])
        print s % tuple(row[:-1]),
        if len(row[-1]):
            print "//", row[-1],
        print

