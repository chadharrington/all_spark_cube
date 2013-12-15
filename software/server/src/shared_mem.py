import ctypes
from ctypes.util import find_library

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
