#!/usr/bin/env python

import csv

with open('usb_sequencer_states.txt', 'U') as csvfile:
    rows = [row for row in csv.reader(csvfile, delimiter='\t')]
    for row in rows[1:]:
        print ('%s: // %s' % tuple(row[0:2]))
        print '  begin'
        print '     data_out = %s;' % row[2]
        print "     output_bits = 5'b%s%s%s%s%s;" % tuple(row[3:8])
        print '  end'

