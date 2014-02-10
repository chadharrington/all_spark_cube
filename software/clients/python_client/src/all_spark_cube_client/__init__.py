import sys
sys.path.append('./gen-py')

from thrift.protocol import TBinaryProtocol
from thrift.transport import TSocket
from thrift.transport import TTransport

from cube_interface import CubeInterface
from cube_interface.ttypes import Color as ThriftColor


class CubeClient(object):
    def __init__(self, host, port):
        socket = TSocket.TSocket(host, port)
        self.transport = TTransport.TBufferedTransport(socket)
        self.protocol = TBinaryProtocol.TBinaryProtocol(self.transport)
        self.client = CubeInterface.Client(self.protocol)
        self.transport.open()        

    def __del__(self):
        self.transport.close()

    def set_data(self, data):
        """Write frame data to the cube"""
        if len(data) != 12288:
            raise ValueError('Length of data parameter must be 12288')
        self.client.set_data(data)
        
Color = ThriftColor
