#include <sys/mman.h>
#include <sys/shm.h>
#include <errno.h>
#include <stdio.h> /* for fprintf */
#include <stdlib.h> /* for exit */

#define SHM_KEY 1278899529
#define SHM_SIZE 12288

typedef unsigned char BYTE;


BYTE* get_shared_mem(int perms) 
{
    int shm_id, retval;
    BYTE* shared_mem;
        
    shm_id = shmget(SHM_KEY, SHM_SIZE, perms);
    if (shm_id == -1) {
        fprintf(stderr, "shmget failed. Errno %d.\n", errno);
        exit(-1);
    }
    shared_mem = (BYTE*) shmat(shm_id, (void*) 0, 0);
    if (shared_mem == (void*) -1) {
        fprintf(stderr, "shmat failed. Errno %d.\n", errno);
        exit(-1);
    }
    retval = mlock(shared_mem, SHM_SIZE);
    if (retval == -1) {
        fprintf(stderr, "mlock failed. Errno %d.\n", errno);
        exit(-1);
    }
    return shared_mem;
}


            
