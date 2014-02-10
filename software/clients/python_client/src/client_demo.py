#!/Usr/bin/env python

from random import randint

from all_spark_cube_client import CubeClient, Color


HOST='cube.ac'
PORT=12345

client = CubeClient(HOST, PORT)

data = [Color(0, 255, 0) for x in range(4096)]
client.set_data(data)

