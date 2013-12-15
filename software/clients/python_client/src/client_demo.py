#!/Usr/bin/env python

from random import randint

from all_spark_cube_client import CubeClient


HOST='192.168.0.100'
PORT=12345

index = 0
data = [randint(0, 255) for x in range(4096 * 3)]

client = CubeClient(HOST, PORT)
client.set_data(index, data)
