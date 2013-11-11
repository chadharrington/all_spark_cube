#!/usr/bin/env python

from itertools import chain
from random import randint
import time

from cube_client import CubeClient

#HOST='10.0.1.100'
HOST='localhost'
PORT=12345


def main():
    data = [(255, 255, 255)
             for x in range(4096)]
    data = list(chain.from_iterable(data))
    client = CubeClient(HOST, PORT)
    reps = 100
    begin = time.clock()
    for i in range(reps):
        client.set_data(0, data)
    end = time.clock()
    duration = end - begin
    print "%d frames in %f secs. %f fps." % (reps, duration, reps / duration)


if __name__ == '__main__':
    main()

