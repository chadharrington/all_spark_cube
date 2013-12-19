#!/usr/bin/env python

import ctypes
from ctypes.util import find_library
import sys
import time

sys.path.append('./gen-py')

from thrift.protocol import TBinaryProtocol
from thrift.server import TServer
from thrift.transport import TSocket
from thrift.transport import TTransport

from cube_interface import CubeInterface


PORT = 12345
IPC_CREAT = 0o1000
SHM_KEY = 1278899529
SHM_SIZE = 12288
SHM_RW_CREATE_PERMS = 0666 | IPC_CREAT


def get_libc():
    return ctypes.CDLL(find_library('c'))


def get_shared_memory(key=SHM_KEY, size=SHM_SIZE, perms=SHM_RW_CREATE_PERMS):
    libc = get_libc()
    shm_id = libc.shmget(key, size, perms)
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


def detach_shared_memory(shm_addr):
    libc = get_libc()
    libc.shmdt(shm_addr)


class CubeHandler(CubeInterface.Iface):
    def __init__(self):
        self.shmaddr = get_shared_memory()
        with open('/opt/adaptive/cube/initialization.bin', 'rb') as f:
            initial_data = [ord(x) for x in f.read()]
        self.max_frames = 300
        self.num_frames = 0
        self.start_time = time.time()
        self.set_data(0, initial_data)

    def __del__(self):
        detach_shared_memory(self.shmaddr)

    def set_data(self, index, data):
        length = len(data)
        data_type = ctypes.c_ubyte * length
        data_array = data_type(*data)
        src_addr = ctypes.byref(data_array)
        ctypes.memmove(self.shmaddr+index, src_addr, length)
        self.num_frames += 1
        if self.num_frames >= self.max_frames:
            end_time = time.time()
            duration = end_time - self.start_time
            self.num_frames = 0
            print '%d frames in %.2f seconds. %.2f fps' % (
                self.max_frames, duration, self.max_frames / duration)
            


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
