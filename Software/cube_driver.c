/* 
   PC to FPGA Command Table
 
   Command           Description                       Operand
   data_bus_in[7:4]                                    data_bus[3:0]
   ----------------  --------------------------------  --------------------
   0 -               Unused / illegal                  N/A
   1 -               Request panel selector data       N/A
   2 -               Set panel address                 {2'b0, panel_addr}
   3 -               Set row address                   row_addr
   4 -               Set chunk address                 chunk_addr
   5 -               Set nibble 0 of chunk             nibble
   6 -               Set nibble 1 of chunk             nibble
   7 -               Set nibble 2 of chunk             nibble
   8 -               Set nibble 3 of chunk             nibble
   9 -               Set nibble 4 of chunk             nibble
   10 -              Set nibble 5 of chunk             nibble
   11 -              Set nibble 6 of chunk             nibble
   12 -              Set nibble 7 of chunk             nibble
   13 -              Write chunk                       N/A
   14 -              Unused / illegal                  N/A
   15 -              Unused / illegal                  N/A

 
 
   FPGA to PC Command Table
 
   Command            Description                       Operand 
   data_bus_out[7:4]                                    data_bus[3:0]
   -----------------  --------------------------------  --------------------
   0 -                Unused / illegal                  N/A
   1 -                Set panel 0 number                panel_switches[3:0]
   2 -                Set panel 1 number                panel_switches[7:4]
   3 -                Set panel 2 number                panel_switches[11:8]
   4 -                Set panel 3 number                panel_switches[15:12]   
   5 -                Unused / illegal                  N/A
   6 -                Unused / illegal                  N/A
   7 -                Unused / illegal                  N/A
   8 -                Unused / illegal                  N/A
   9 -                Unused / illegal                  N/A
   10 -               Unused / illegal                  N/A
   10 -               Unused / illegal                  N/A
   11 -               Unused / illegal                  N/A
   12 -               Unused / illegal                  N/A
   13 -               Unused / illegal                  N/A
   14 -               Unused / illegal                  N/A
   15 -               Unused / illegal                  N/A

*/

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/shm.h>
#include <time.h>

#include "ftd2xx.h"

#define BYTE unsigned char

#define SHM_SIZE 12288
#define SHM_PERMS 0666
#define SHM_FILENAME "/opt/adaptive/cube/cubememory"
#define SHM_ID 1
#define INIT_FILE_NAME "/opt/adaptive/cube/initialization.bin"
#define MAX_BOARDS 10
#define SERIAL_NUM_SIZE 17
#define DEVICE_DESCRIPTION_SIZE 64
#define NUM_PANELS_PER_BOARD 4
#define SEND_BUFFER_SIZE 10000

typedef enum {FPGA_RESET, FPGA_RUN} FPGA_MODE;
typedef struct 
{
    FT_HANDLE handle;
    BYTE      serial_num[SERIAL_NUM_SIZE];
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
    nanosleep(&t, &r) ;
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
    retval = FT_SetUSBParameters(info->handle, 64, 0);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_SetUSBParameters failed: %d\n", retval);
        exit(-1);
    }
    retval = FT_SetLatencyTimer(info->handle, 2);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_SetLatencyTimer failed: %d\n", retval);
        exit(-1);
    }
    retval = FT_SetTimeouts(info->handle, 1000, 1000);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_SetTimeouts failed: %d\n", retval);
        exit(-1);
    }
    set_fpga_mode(info->handle, FPGA_RESET);
    sleep_ms(1);
    set_fpga_mode(info->handle, FPGA_RUN);
    sleep_ms(1);
}

void send_command_impl(FT_HANDLE handle, BYTE command, BYTE operand,
                       int send_immediately)
{
    FT_STATUS retval;
    BYTE data_out;
    DWORD bytes_written;
    static BYTE send_buffer[SEND_BUFFER_SIZE];
    static DWORD send_buffer_index=0;
    
    if ((command > 13) || (command < 1)) {
        fprintf(stderr, "Command %d is not a valid command.\n", command);
        exit(-1);
    }
    if (operand > 15) {
        fprintf(stderr, "Operand %d is too large.\n", operand);
        exit(-1);
    }
    data_out = (command << 4) | operand;
    send_buffer[send_buffer_index++] = data_out;
    
    if (send_immediately || send_buffer_index >= SEND_BUFFER_SIZE) {
        
        retval = FT_Write(handle, &send_buffer, 
                          send_buffer_index, &bytes_written);
        if (retval != FT_OK) {
            fprintf(stderr, "FT_Write failed: %d\n", retval);
            exit(-1);
        }
        if (bytes_written != send_buffer_index) {
            fprintf(stderr, "FT_Write returned wrong count. ");
            fprintf(stderr, "Expected %d. Returned: %d\n", 
                    send_buffer_index, bytes_written);
            exit(-1);
        }
        send_buffer_index = 0;
    }
}

void send_command(FT_HANDLE handle, BYTE command, BYTE operand) 
{
    send_command_impl(handle, command, operand, 0);
}

void send_command_immediately(FT_HANDLE handle, BYTE command, BYTE operand)
{
    send_command_impl(handle, command, operand, 1);
}

void set_serial_number(BOARD_INFO* board_info) 
{
    FT_STATUS retval;
    FT_DEVICE device_type;
    DWORD device_id;
    char  serial_num[SERIAL_NUM_SIZE];
    char  device_description[DEVICE_DESCRIPTION_SIZE];
    int i;
    
    retval = FT_GetDeviceInfo(board_info->handle, &device_type, &device_id,
                              serial_num, device_description, NULL);
    if (retval != FT_OK) {
        fprintf(stderr, "FT_GetDeviceInfo failed: %d\n", retval);
        exit(-1);
    }
    for (i=0; i<SERIAL_NUM_SIZE; ++i) {
        board_info->serial_num[i] = serial_num[i];
    }
}

void set_panel_info(BOARD_INFO* board_info) 
{
    BYTE data_in[4];
    BYTE command, operand;
    FT_STATUS retval;
    DWORD bytes_written = 0;
    DWORD bytes_in_rx_queue = 0;
    DWORD bytes_in_tx_queue = 0;
    DWORD bytes_read = 0;
    DWORD event_status = 0;
    int i;

    set_serial_number(board_info);
    // We have to send the command twice, not sure why
    for (i=0; i<2; ++i) {  
        command = 1; // Request panel selector data command
        operand = 0;
        send_command_immediately(board_info->handle, command, operand);
    }
    while (bytes_in_rx_queue < 4) {
        retval = FT_GetStatus(board_info->handle, &bytes_in_rx_queue, 
                              &bytes_in_tx_queue, &event_status);
        if (retval != FT_OK) {
            fprintf(stderr, "set_panel_info::FT_GetQueueStatus failed: %d\n",
                    retval);
            exit(-1);
        }
    }
    retval = FT_Read(board_info->handle, &data_in, 4, &bytes_read);
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
        if (command > 4) {
            fprintf(stderr, "Received invalid command: %d\n", command);
            exit(-1); 
        }
        board_info->panel_nums[command-1] = operand;
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

void print_board_info(BOARD_INFO board_info_array[]) 
{
    int i, j;

    for (i=0; i<MAX_BOARDS; ++i) {
        if (board_info_array[i].handle == NULL) continue;
        printf("Board %d:\n", i);
        printf("  handle: %p\n", board_info_array[i].handle);
        printf("  serial num: %s\n", board_info_array[i].serial_num);
        for (j=0; j<4; ++j)
            printf("  panel_nums[%d]: %d\n", j, 
                   board_info_array[i].panel_nums[j]);        
    }
}

void send_chunk(FT_HANDLE handle, BYTE panel_addr, BYTE row_addr, 
                BYTE chunk_addr, BYTE* chunk_data)
{
    int i;
    BYTE data;

    if (panel_addr > 3) {
        fprintf(stderr, "Invalid panel address: %u", panel_addr);
        exit(-1);
    }
    send_command(handle, 2, panel_addr); 
    send_command(handle, 3, row_addr); 
    send_command(handle, 4, chunk_addr);
    for (i=0; i<8; ++i) {
        data = *(chunk_data+(i/2));
        if (i % 2) data = (data & 0xf0) >> 4;
        else data = data & 0x0f;
        send_command(handle, i+5, data); // Send nibbles
    }
    send_command(handle, 13, 0);  // Write chunk
}

void send_row(FT_HANDLE handle, BYTE panel_addr, 
              BYTE row_addr, BYTE* row_data)
{
    int i;
    
    for (i=0; i<12; ++i) {
        send_chunk(handle, panel_addr, row_addr, i, row_data+(i*4));
    }
}

void send_panel(FT_HANDLE handle, BYTE panel_addr, BYTE* panel_data)
{
    int i;
    
    for(i=0; i<16; ++i) {
        send_row(handle, panel_addr, i, panel_data+(i*48));
    }
}

void send_data_to_boards(BYTE* shared_mem, BOARD_INFO board_info_array[])
{
    BYTE i, j, panel;
    FT_HANDLE handle;
    
    for (i=0; i<MAX_BOARDS; ++i) {
        handle = board_info_array[i].handle;
        if (handle != NULL) {
            for (j=0; j<4; ++j) {
                panel = board_info_array[i].panel_nums[j];
                send_panel(handle, j, shared_mem+(panel*768));
            }
        }
    }
}

int main() 
{
    BYTE* shared_mem=NULL;
    BOARD_INFO board_info_array[MAX_BOARDS];
    int i, duration;
    int reps = 10000;
    time_t start_time, end_time;

    shared_mem = create_shared_mem();
    initialize_shared_memory(shared_mem);
    initialize_driver_boards(&board_info_array);
    print_board_info(board_info_array);

    while (1) {
        time(&start_time);
        for (i=0; i<reps; ++i) {
            send_data_to_boards(shared_mem, board_info_array);
        }
        time(&end_time);
        duration = difftime(end_time, start_time);
        printf("%d frames in %d secs. %.2f fps.\n",
               reps, duration, (float) reps / (float) duration);
    }
    return 0;
}
