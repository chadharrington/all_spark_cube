
from thrift.protocol import TBinaryProtocol
from thrift.transport import TSocket
from thrift.transport import TTransport

from cube import CubeInterface


class CubeClient(object):
    def __init__(self, host, port):
        socket = TSocket.TSocket(host, port)
        self.transport = TTransport.TBufferedTransport(socket)
        protocol = TBinaryProtocol.TBinaryProtocol(self.transport)
        self.client = CubeInterface.Client(protocol)
        self.transport.open()        

    def __del__(self):
        self.transport.close()

    def set_data(self, index, data):
        """Write color data to the cube, starting at index"""
        self.client.set_data(index, data)
        
