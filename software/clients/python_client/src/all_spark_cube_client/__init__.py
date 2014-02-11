import sys
sys.path.append('./gen-py')

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


class CubeClient(object):
    def __init__(self, host, port):
        socket = TSocket.TSocket(host, port)
        self.transport = TTransport.TBufferedTransport(socket)
        self.protocol = TBinaryProtocol.TBinaryProtocol(self.transport)
        self.client = CubeInterface.Client(self.protocol)
        self.transport.open()        

    def __del__(self):
        self.transport.close()

    def set_colors(self, colors):
        """Write color data to the cube"""
        if len(colors) != NUM_VOXELS:
            raise ValueError('The length of the colors array must be 4096')
        data = []
        for color in colors:
            data.append(color.red)
            data.append(color.green)
            data.append(color.blue)
        self.client.set_data(data)
        
