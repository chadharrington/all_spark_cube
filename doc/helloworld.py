# hello world example
# first downlaod the client application, or compile from source
# the client application is not yet available from the github page
# you can get it by contacting the author

from all_spark_cube_client import *

HOST = 192.168.1.10
PORT='12345'

client = CubeClient(HOST,PORT)

# Turn led 0 red
client.set_data(0, [255, 0, 0])

# Turn led 4095 green 
client.set_data(4095, [0,255,  0])
