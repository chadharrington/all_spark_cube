#!/usr/bin/env python

import time
import socket

#HOST = 'cube.ac'
HOST = 'localhost'
PORT = 12345
NUM_LEDS = 4096
BUF_SIZE = NUM_LEDS * 3 # There are 3 bytes (R,G, & B) for each LED


def main():
    buffer = bytearray(BUF_SIZE)
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    # The next line is important for Mac OS X users. The default send buffer
    # is too small for our purposes.
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, BUF_SIZE)
    
    #Turn the whole cube blue (0, 0, 255)
    for led in range(NUM_LEDS):
        buffer[led * 3] = 0     # Red
        buffer[led * 3 + 1] = 0   # Green
        buffer[led * 3 + 2] = 255   # Blue


    reps = 500
    while True:
        start = time.time()
        for x in range(reps):
            sock.sendto(buffer, (HOST, PORT))
            time.sleep(0.01)   # Limit to ~100 fps
        duration = time.time() - start
        print '%d frames in %.2f secs. (%.2f fps)' % (
                reps, duration, reps / float(duration))


if __name__ == '__main__':
    main()

