#!/usr/bin/env python

import ctypes
import platform

from thrift.protocol import TBinaryProtocol
from thrift.server import TServer
from thrift.transport import TSocket
from thrift.transport import TTransport

from cube import CubeInterface

PORT = 12345
SHM_KEY = 1278899529
SHM_SIZE = 12288
SHM_PERMS = 0666


def get_libc():
    system = platform.system()
    if system == 'Darwin':
        return ctypes.CDLL("libc.dylib")
    elif system == 'Linux':
        return ctypes.CDLL("libc.so.6")
    else:
        raise Exception('Unknown system type:', system)


def get_shared_memory(libc):
    shm_id = libc.shmget(SHM_KEY, SHM_SIZE, SHM_PERMS)
    if shm_id == -1:
        raise Exception('Could not get shared memory with key %d' % SHM_KEY)
    shmat = libc.shmat
    shmat.argtypes = [ctypes.c_int,
                      ctypes.POINTER(ctypes.c_void_p), ctypes.c_int]
    shmat.restype = ctypes.c_void_p
    shm_addr = shmat(shm_id, None, 0)
    if shm_addr == -1:
        raise Exception('Could not attach to shared memory id %d' % shm_id)
    return shm_addr


class CubeHandler(CubeInterface.Iface):
    def __init__(self):
        self.libc = get_libc()
        self.shmem = get_shared_memory(self.libc)

    def __del__(self):
        self.libc.shmdt(self.shmem)

    def set_data(self, index, data):
        length = len(data)
        data_type = ctypes.c_ubyte * length
        data_array = data_type(*data)
        src_addr = ctypes.byref(data_array)
        ctypes.memmove(self.shmem+index, src_addr, length)


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
