
from random import randint

from cube_client import CubeClient


#HOST='10.0.1.100'
HOST='localhost'
PORT=12345

data = [randint(0, 255) for x in range(4096 * 3)]

client = CubeClient(HOST, PORT)

client.set_data(0, data)

print 'Done.'
