#!/Usr/bin/env python

from all_spark_cube_client import CubeClient
from colors import red

HOST='cube.ac'
PORT=12345

colors = [red for x in range(4096)]
client = CubeClient(HOST, PORT)
client.set_colors(colors)
