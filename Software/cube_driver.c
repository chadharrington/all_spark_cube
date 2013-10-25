
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/shm.h>

#include "ftd2xx.h"

#define BYTE unsigned char

#define SHM_SIZE 12288
#define SHM_PERMS 0666
#define SHM_FILENAME "/opt/adaptive/cube/cubememory"
#define SHM_ID 1
#define INIT_FILE_NAME "/opt/adaptive/cube/initialization.bin"

BYTE* get_shared_mem() 
{
    key_t shm_key;
    int shm_id, retval;
    BYTE* shared_mem;
        
    shm_key = ftok(SHM_FILENAME, SHM_ID);
    if (shm_key == -1) {
        printf("ftok(%s, %d) failed. Errno: %d.\n", 
               SHM_FILENAME, SHM_ID, errno);
        exit(-1);
    }
    
    shm_id = shmget(shm_key, SHM_SIZE, SHM_PERMS | IPC_CREAT);
    if (shm_id == -1) {
        printf("shmget failed. Errno %d.\n", errno);
        exit(-1);
    }
    
    shared_mem = shmat(shm_id, (void*) 0, 0);
    if (shared_mem == (void*) -1) {
        printf("shmat failed. Errno %d.\n", errno);
        exit(-1);
    }

    retval = mlock(shared_mem, SHM_SIZE);
    if (retval == -1) {
        printf("mlock failed. Errno %d.\n", errno);
        exit(-1);
    }
    return shared_mem;
}


int main() 
{
    BYTE* shared_mem;
    FILE* init_data_file;
    unsigned int num_read;

    shared_mem = get_shared_mem();
    //printf("shared_mem_addr: %ld\n", (long unsigned int) shared_mem);

    shared_mem[0] = 12;
    shared_mem[1] = 200;
    shared_mem[12000] = 234;
    
    printf("0:%d 1:%d 2:%d 3:%d 12000:%d\n", 
           shared_mem[0], shared_mem[1], shared_mem[2], 
           shared_mem[3], shared_mem[12000]);

    init_data_file = fopen(INIT_FILE_NAME, "rb");
    if (init_data_file == NULL) {
        printf("Failed to open initialization file: %s\n", INIT_FILE_NAME);
        printf("Errno: %d\n", errno);
        exit(-1);
    }
    num_read = fread(shared_mem, 1, SHM_SIZE, init_data_file);
    if (num_read != SHM_SIZE) {
        printf("fread returned wrong count: %u instead of %u\n", 
               num_read, SHM_SIZE);
        exit(-1);
    }
    fclose(init_data_file);
    

    printf("0:%d 1:%d 2:%d 3:%d 12000:%d\n", 
           shared_mem[0], shared_mem[1], shared_mem[2], 
           shared_mem[3], shared_mem[12000]);
    
    return 0;
}


