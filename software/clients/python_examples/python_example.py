import socket

HOST = 'cube.ac'
#HOST = 'localhost'
PORT = 12345
NUM_LEDS = 4096
BUF_SIZE = NUM_LEDS * 3 # There are 3 bytes (R,G, & B) for each LED


buffer = bytearray(BUF_SIZE)
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
# The next line is important for Mac OS X users. The default send buffer
# is too small for our purposes.
sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, BUF_SIZE)

#Turn the whole cube red (255, 0, 0)
for led in range(NUM_LEDS):
    buffer[led * 3] = 255     # Red
    buffer[led * 3 + 1] = 0   # Green
    buffer[led * 3 + 2] = 0   # Blue
# Cube won't display more than 100 frames per second.
# Don't send more than that.
sock.sendto(buffer, (HOST, PORT)) 

#Turn the second LED blue
led = 1 
buffer[led * 3] = 0       # Red
buffer[led * 3 + 1] = 0   # Green
buffer[led * 3 + 2] = 255   # Blue
sock.sendto(buffer, (HOST, PORT))
