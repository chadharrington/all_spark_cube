import sys

from thrift.protocol import TBinaryProtocol
from thrift.transport import TSocket
from thrift.transport import TTransport

from cube_interface import CubeInterface

NUM_VOXELS = 4096


class Color(object):
    def __init__(self, red, green, blue):
        self.red = red
        self.green = green 
        self.blue = blue


class Colors(object):
        yellow = Color(255, 255, 0)
        cyan = Color(0, 255, 255)
        magenta = Color(255, 0, 255)
        red = Color(255, 0, 0)
        green = Color(0, 255, 0)
        blue = Color(0, 0, 255)
        white = Color(255, 255, 255)
        black = Color(0, 0, 0)
        gray = Color(100, 100, 100)
        dark_green = Color(36, 84, 48)
        orange = Color(255, 127, 0)
        light_yellow = Color(127, 127, 0)
        pink = Color(255, 192, 203)


class CubeClient(object):
    def __init__(self, host, port):
        socket = TSocket.TSocket(host, port)
        self.transport = TTransport.TBufferedTransport(socket)
        self.protocol = TBinaryProtocol.TBinaryProtocol(self.transport)
        self.client = CubeInterface.Client(self.protocol)
        self.transport.open()
        self.buffer = [0 for x in range(NUM_VOXELS *3)]

    def __del__(self):
        self.transport.close()

    def set_led(self, led_num, color):
        """Set a single LED to the specified color."""
        self.buffer[led_num * 3] = color.red
        self.buffer[led_num * 3 + 1] = color.green
        self.buffer[led_num * 3 + 2] = color.blue

    def set_led_range(self, led_num_start, num_leds, color):
        """Set a range of LEDs to the specified color."""
        for i in range(led_num_start, led_num_start + num_leds):
            self.set_led(i, color)

    def set_all_leds(self, color):
        """Set all LEDs to the specified color."""
        self.set_led_range(0, 4096, color)

    def send(self):
        """Actually send the data to the cube."""
        self.client.set_data(self.buffer)
        
