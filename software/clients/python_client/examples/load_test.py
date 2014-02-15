#!/usr/bin/env python

import time

from all_spark_cube_client import CubeClient, Colors

#HOST = 'localhost'
HOST='cube.ac'
PORT=12345


def main():
    client = CubeClient(HOST, PORT)
    client.set_all_leds(Colors.yellow)
    client.set_led(15, Colors.blue)

    reps = 500
    while True:
        start = time.time()
        for x in range(reps):
            client.send()
        duration = time.time() - start
        print '%d frames in %.2f secs. (%.2f fps)' % (
                reps, duration, reps / float(duration))


if __name__ == '__main__':
    main()

