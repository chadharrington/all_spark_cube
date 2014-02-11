import time

from all_spark_cube_client import CubeClient
from colors import *

HOST='cube.ac'
PORT=12345


def main():
    buffer = [orange for x in range(4096)]
    client = CubeClient(HOST, PORT)
    reps = 300
    while True:
        start = time.time()
        for x in range(reps):
            client.set_colors(buffer)
        duration = time.time() - start
        print '%d frames in %.2f secs. %.2f fps.' % (
                reps, duration, reps / float(duration))


if __name__ == '__main__':
    main()

