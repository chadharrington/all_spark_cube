#!/Usr/bin/env python

from thrift.protocol import TBinaryProtocol
from thrift.server import TServer
from thrift.transport import TSocket
from thrift.transport import TTransport

from all_spark_cube import CubeInterface

PORT = 12345


class CubeHandler(CubeInterface.Iface):
    def set_data(self, index, data):
        print 'Got data. Index: %d - Data length: %d' % (index, len(data))


def main():
    processor = CubeInterface.Processor(CubeHandler())
    transport = TSocket.TServerSocket(port=PORT)
    tfactory = TTransport.TBufferedTransportFactory()
    pfactory = TBinaryProtocol.TBinaryProtocolFactory()
    server = TServer.TThreadedServer(processor, transport, tfactory, pfactory)

    print 'Starting the server...'
    server.serve()


if __name__ == '__main__':
    main()
