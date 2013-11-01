
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
    
    
    
BYTE* create_shared_mem() 
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

void sleep_ms(int milliseconds) 
{
    struct timespec t, r;
    t.tv_sec = 1;
    t.tv_nsec = milliseconds * 1000000L;
    nanosleep(&t , &r) ;
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

void purge_buffers(FT_HANDLE handle) 
{
    FT_STATUS retval;

    retval = FT_ResetDevice(handle);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_ResetDevice failed: %d\n", retval);
        exit(-1);
    }
    do { 
        retval = FT_StopInTask(handle); 
    } while (retval != FT_OK); 
    retval = FT_Purge(handle, FT_PURGE_RX | FT_PURGE_TX);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_Purge failed: %d\n", retval);
        exit(-1);
    }
    do { 
        retval = FT_RestartInTask(handle); 
    } while (retval != FT_OK); 
}

void set_board_parameters(BOARD_INFO* info) 
{
    FT_STATUS retval;
    
    purge_buffers(info->handle);
    retval = FT_SetUSBParameters(info->handle, 64, 64*1024);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_SetUSBParameters failed: %d\n", retval);
        exit(-1);
    }
    retval = FT_SetLatencyTimer(info->handle, 2);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_SetLatencyTimer failed: %d\n", retval);
        exit(-1);
    }
    retval = FT_SetTimeouts(info->handle, 10, 5000);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_SetTimeouts failed: %d\n", retval);
        exit(-1);
    }

    set_fpga_mode(info->handle, FPGA_RESET);
    sleep_ms(1);
    set_fpga_mode(info->handle, FPGA_RUN);
    sleep_ms(1);
}

void set_panel_info(BOARD_INFO* info) 
{
    BYTE data_out = 0x10;  // Request panel selector data command
    BYTE data_in[4];
    BYTE command, operand;
    FT_STATUS retval;
    DWORD bytes_written = 0;
    DWORD bytes_in_rx_queue = 0;
    DWORD bytes_in_tx_queue = 0;
    DWORD bytes_read = 0;
    DWORD event_status = 0;
    int i;

    for (i=0; i<2; ++i) {  // We have to send the command twice, not
                           // sure why.
        retval = FT_Write(info->handle, &data_out, 1, &bytes_written);
        if (retval != FT_OK) {
            fprintf(stderr, "set_panel_info::FT_Write failed: %d\n", retval);
            exit(-1);
        }
        if (bytes_written != 1) {
            fprintf(stderr, "set_panel_info::FT_Write returned wrong count.");
            fprintf(stderr, "Expected 1. Returned: %d\n", bytes_written);
            exit(-1);
        }
    }

    while (bytes_in_rx_queue < 4) {
        retval = FT_GetStatus(info->handle, &bytes_in_rx_queue, 
                              &bytes_in_tx_queue, &event_status);
        if (retval != FT_OK) {
            fprintf(stderr, "set_panel_info::FT_GetQueueStatus failed: %d\n",
                    retval);
            exit(-1);
        }
    }
    retval = FT_Read(info->handle, &data_in, 4, &bytes_read);
    if (retval != FT_OK) {
        fprintf(stderr, "set_panel_info::FT_Read failed: %d\n", retval);
        exit(-1);
    }
    if (bytes_read != 4) {
        fprintf(stderr, "set_panel_info::FT_Read returned wrong byte count.");
        fprintf(stderr, "Expected 4. Returned: %d\n", bytes_written);
        exit(-1);
    }
    for (i=0; i<4; ++i) {
        command = data_in[i] >> 4;
        operand = data_in[i] & 0x0f;
        switch (command) {
        case 1:
            info->panel_nums[0] = operand;
            break;
        case 2:
            info->panel_nums[1] = operand;
            break;
        case 3:
            info->panel_nums[2] = operand;
            break;
        case 4:
            info->panel_nums[3] = operand;
            break;
        default:
            fprintf(stderr, "Received invalid command: %d\n", command);
            exit(-1); 
        }
    }
}
    
void initialize_driver_boards(BOARD_INFO (*board_info_array)[])
{
    FT_STATUS retval;
    DWORD num_devices, i;
    int board_num=0;
    FT_DEVICE_LIST_INFO_NODE* info_array=NULL;
    BOARD_INFO* info;

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
            info = &(*board_info_array)[i];
            set_board_parameters(info);
            set_panel_info(info);
        }
    }
    if (info_array != NULL) free(info_array);    
}

int main() 
{
    BYTE* shared_mem=NULL;
    BOARD_INFO board_info_array[MAX_BOARDS];
    int i, j;

    shared_mem = create_shared_mem();
    initialize_shared_memory(shared_mem);
    initialize_driver_boards(&board_info_array);

    for (i=0; i<MAX_BOARDS; ++i) {
        if (board_info_array[i].handle == NULL) continue;
        printf("Board %d:\n", i);
        printf("  handle: %p\n", board_info_array[i].handle);
        for (j=0; j<4; ++j)
            printf("  panel_nums[%d]: %d\n", j, board_info_array[i].panel_nums[j]);        
    }

    return 0;
}


