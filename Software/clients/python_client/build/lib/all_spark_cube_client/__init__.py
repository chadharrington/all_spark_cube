from thrift.protocol import TBinaryProtocol
from thrift.transport import TSocket
from thrift.transport import TTransport

from all_spark_cube import CubeInterface


class AllSparkCubeClient(object):
    def __init__(self, host, port):
        socket = TSocket.TSocket(host, port)
        self.transport = TTransport.TBufferedTransport(socket)
        self.protocol = TBinaryProtocol.TBinaryProtocol(self.transport)
        self.client = CubeInterface.Client(self.protocol)
        self.transport.open()        

    def __del__(self):
        self.transport.close()

    def set_data(self, index, data):
        """Write color data to the cube, starting at index"""
        self.client.set_data(index, data)
        
