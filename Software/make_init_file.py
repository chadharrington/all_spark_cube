#!/usr/bin/env python

import os

def make_random_file(filename, length):
    with open(filename, 'wb') as f:
        f.write(os.urandom(length))
    print filename, 'created.'

if __name__ == '__main__':
    make_random_file('/opt/adaptive/cube/initialization.bin', 12288)
