#include <stdio.h>  /* for printf */
#include <stdlib.h> /* for atoi */

#include "shmem.h"

#define SHM_PERMS 0444

int main(int argc, char** argv)
{
    BYTE* shmem;
    unsigned int bytenum;

    if (argc == 2) {
        bytenum = atoi(argv[1]);
        shmem = get_shared_mem(SHM_PERMS);
        printf("Byte %u: %u\n", bytenum, shmem[bytenum]);
    } else {
        fprintf(stderr, "Usage: %s <byte_num>\n", argv[0]);
        exit(-1);
    }
}
