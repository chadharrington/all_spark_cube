
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/shm.h>

#include "ftd2xx.h"

#define BYTE unsigned char

#define SHM_SIZE 12288
#define SHM_PERMS 0666
#define SHM_FILENAME "/opt/adaptive/cube/cubememory"
#define SHM_ID 1
#define INIT_FILE_NAME "/opt/adaptive/cube/initialization.bin"
#define MAX_BOARDS 10
#define NUM_PANELS_PER_BOARD 4

typedef enum {FPGA_RESET, FPGA_RUN} FPGA_MODE;
typedef struct 
{
    FT_HANDLE handle;
    BYTE      panel_nums[NUM_PANELS_PER_BOARD];
} BOARD_INFO;
    
    
    
BYTE* get_shared_mem() 
{
    key_t shm_key;
    int shm_id, retval;
    BYTE* shared_mem;
        
    shm_key = ftok(SHM_FILENAME, SHM_ID);
    if (shm_key == -1) {
        fprintf(stderr, "ftok(%s, %d) failed. Errno: %d.\n", 
               SHM_FILENAME, SHM_ID, errno);
        exit(-1);
    }
    
    shm_id = shmget(shm_key, SHM_SIZE, SHM_PERMS | IPC_CREAT);
    if (shm_id == -1) {
        fprintf(stderr, "shmget failed. Errno %d.\n", errno);
        exit(-1);
    }
    
    shared_mem = shmat(shm_id, (void*) 0, 0);
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

void initialize_shared_memory(BYTE* shared_mem)
{
    FILE* init_data_file;
    unsigned int num_read;

    init_data_file = fopen(INIT_FILE_NAME, "rb");
    if (init_data_file == NULL) {
        fprintf(stderr, "Failed to open initialization file: %s\n", INIT_FILE_NAME);
        fprintf(stderr, "Errno: %d\n", errno);
        exit(-1);
    }

    num_read = fread(shared_mem, 1, SHM_SIZE, init_data_file);
    if (num_read != SHM_SIZE) {
        fprintf(stderr, "fread returned wrong count: %u instead of %u\n", 
               num_read, SHM_SIZE);
        exit(-1);
    }
    fclose(init_data_file);
}

void set_fpga_mode(FT_HANDLE board_handle, FPGA_MODE mode) 
{
    FT_STATUS retval;

    /* ACBUS5 on the UM232H is connected to the FPGA reset line.
       We use CBUS BitBang mode to manipulate it. */
    retval = FT_SetBitMode(board_handle, 0x10 | mode, 0x20);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_SetBitMode failed: %d\n", retval);
        exit(-1);
    }
}

void initialize_driver_boards(BOARD_INFO (*board_info_array)[])
{
    FT_STATUS retval;
    DWORD num_devices, i;
    int board_num=0;
    FT_DEVICE_LIST_INFO_NODE* info_array=NULL;

    for (i=0; i<MAX_BOARDS; ++i) {
        (*board_info_array)[i].handle = NULL;
    }
    
    retval = FT_CreateDeviceInfoList(&num_devices);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_CreateDeviceInfoList failed: %d\n", retval);
        exit(-1);
    }

    if (num_devices <= 0) {
        fprintf(stderr, "No USB devices found.\n");
        exit(-1);
    }
    
    info_array = (FT_DEVICE_LIST_INFO_NODE*) malloc(
        sizeof(FT_DEVICE_LIST_INFO_NODE) * num_devices);
    retval = FT_GetDeviceInfoList(info_array, &num_devices);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_GetDeviceInfoList failed: %d\n", retval);
        exit(-1);
    }

    for (i=0; i<num_devices; ++i) {
        if (strncmp(info_array[i].Description, "Cube Driver Board", 17) == 0) {
            retval = FT_OpenEx(info_array[i].SerialNumber, 
                               FT_OPEN_BY_SERIAL_NUMBER, 
                               &((*board_info_array)[board_num++].handle));
            if (retval != FT_OK) {
                fprintf(stderr, "FT_OpenEx failed: %d\n", retval);
                exit(-1);
            }
            if (board_num >= MAX_BOARDS) {
                fprintf(stderr,
                        "More than %d driver boards are connected. Exiting.\n",
                        MAX_BOARDS);
                exit(-1);
            }
        }
    }

    for(i=0; i<MAX_BOARDS; ++i) {
        if ((*board_info_array)[i].handle != NULL) {
            set_fpga_mode((*board_info_array)[i].handle, FPGA_RUN);
        }
    }
    if (info_array != NULL) free(info_array);    
}
int main() 
{
    BYTE* shared_mem=NULL;
    BOARD_INFO board_info_array[MAX_BOARDS];

    shared_mem = get_shared_mem();
    initialize_shared_memory(shared_mem);
    initialize_driver_boards(&board_info_array);

    
    return 0;
}


