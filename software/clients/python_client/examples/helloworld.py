#!/usr/bin/env python

from all_spark_cube_client import CubeClient, Color, Colors


#HOST = 'localhost'
HOST = 'cube.ac'
PORT = 12345


client = CubeClient(HOST, PORT)

# Set all LEDs to blue
client.set_all_leds(Colors.blue)

# Set the first LED (#0) to red
client.set_led(0, Colors.red)

# Set the second LED (#1) to a custom color (teal-ish)
client.set_led(1, Color(100, 255, 95))

# Starting at LED #48, set 16 LEDs to yellow
client.set_led_range(48, 16, Colors.yellow)

# Set the last LED (#4095) to green
client.set_led(4095, Colors.green)

# Actually send the data to the cube
client.send();  

print 'Success...'

