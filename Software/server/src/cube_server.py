#!/usr/bin/env python

import ctypes
import sys
sys.path.append('./gen-py')

from thrift.protocol import TBinaryProtocol
from thrift.server import TServer
from thrift.transport import TSocket
from thrift.transport import TTransport

from cube_interface import CubeInterface
from shared_mem import get_shared_memory, detach_shared_memory


PORT = 12345


class CubeHandler(CubeInterface.Iface):
    def __init__(self):
        self.shmaddr = get_shared_memory()
        with open('/opt/adaptive/cube/initialization.bin', 'rb') as f:
            initial_data = [ord(x) for x in f.read()]
        self.set_data(0, initial_data)

    def __del__(self):
        detach_shared_memory(self.shmaddr)

    def set_data(self, index, data):
        length = len(data)
        data_type = ctypes.c_ubyte * length
        data_array = data_type(*data)
        src_addr = ctypes.byref(data_array)
        ctypes.memmove(self.shmaddr+index, src_addr, length)


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
