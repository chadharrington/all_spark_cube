
import csv
import sys

if len(sys.argv) != 2:
    print 'Usage: %s <input-filename>' % sys.argv[0]
    sys.exit(-1)

with open(sys.argv[1], 'U') as csvfile:
    rows = [row for row in csv.reader(csvfile, delimiter='\t')]
    for row in rows[1:]:
        if len(row[0]) == 0:
            sys.exit(0)
        s = "6'd%02d: rom_data = 5'b%s%s%s%s%s;"
        row[0] = int(row[0])
        print s % tuple(row[:-1]),
        if len(row[-1]):
            print "//", row[-1],
        print

