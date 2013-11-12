#!/Usr/bin/env python

from random import randint

from all_spark_cube_client import AllSparkCubeClient


HOST='localhost'
PORT=12345

index = 0
data = [randint(0, 255) for x in range(4096 * 3)]

client = AllSparkCubeClient(HOST, PORT)
client.set_data(index, data)
