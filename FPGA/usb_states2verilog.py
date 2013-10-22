#!/usr/bin/env python

import csv

with open('usb_sequencer_states.txt', 'U') as csvfile:
    rows = [row for row in csv.reader(csvfile, delimiter='\t')]
    for row in rows[1:]:
        print ('%s: // %s' % tuple(row[0:2]))
        print '  begin'
        print '     data_bus_raw = %s;' % row[2]
        print '     rd_n = %s;' % row[3]
        print '     wr_n = %s;' % row[4]
        print '     cmd_we = %s;' % row[5]
        print '  end'

