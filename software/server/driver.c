/* 
   PC to FPGA Command Table
 
   Command           Description                       Operand
   data_bus_in[7:4]                                    data_bus[3:0]
   ----------------  --------------------------------  --------------------
   0 -               Unused / illegal                  N/A
   1 -               Request panel numbers             N/A
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
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/shm.h>
#include <time.h>

#include <ftdi.h> 

#define SHM_KEY 1278899529
#define SHM_SIZE 12288
#define SHM_PERMS 0444
#define MAX_BOARDS 10
#define NUM_BYTES_PER_CHUNK 4
#define NUM_NIBBLES_PER_CHUNK NUM_BYTES_PER_CHUNK * 2
#define NUM_PANELS_PER_BOARD 4
#define NUM_ROWS 16
#define NUM_COLS 16
#define NUM_BYTES_PER_VOXEL 3
#define NUM_BYTES_PER_ROW NUM_COLS * NUM_BYTES_PER_VOXEL
#define NUM_BYTES_PER_PANEL NUM_ROWS * NUM_BYTES_PER_ROW
#define NUM_CHUNKS_PER_ROW NUM_BYTES_PER_ROW / NUM_BYTES_PER_CHUNK
#define SEND_BUFFER_SIZE 10000
#define READ_BUFFER_SIZE 1

/* FTDI Constants */
#define SERIAL_NUM_SIZE 17
#define DESCRIPTION_STRING "Cube Driver Board"
#define DESCRIPTION_SIZE 64
#define MANUFACTURER_SIZE 64
#define VENDOR_ID 0x403
#define PRODUCT_ID 0x6014

typedef enum {FPGA_RESET, FPGA_RUN} FPGA_MODE;
typedef unsigned char BYTE;
typedef struct ftdi_context context;
typedef struct 
{
    context     device_context;
    context*    handle;
    char        serial_num[SERIAL_NUM_SIZE];
    BYTE        panel_nums[NUM_PANELS_PER_BOARD];
    BYTE        send_buffer[SEND_BUFFER_SIZE];
    int         send_buffer_index;
    BYTE*       shmem;
} board_t;


BYTE* create_shared_mem() 
{
    int shm_id, retval;
    BYTE* shared_mem;
        
    shm_id = shmget(SHM_KEY, SHM_SIZE, SHM_PERMS);
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


void exit_with_error(context* handle, char* func_name, int val) 
{
    fprintf(stderr, "%s failed:%d (%s)\n", func_name,
            val, ftdi_get_error_string(handle));
    ftdi_free(handle);
    exit(-1);
}
        

void init_handle(context* handle)
{
    int ret;
    
    ret = ftdi_init(handle);
    if (ret != 0) {
        fprintf(stderr, "ftdi_init failed:%d\n", ret);
        exit(-1);
    }
}


void set_fpga_mode(board_t* board, int mode) 
{
    int ret;
    
    ret = ftdi_set_bitmode(board->handle, 0x10 | mode, BITMODE_CBUS);
    if (ret != 0) 
        exit_with_error(board->handle, "ftdi_set_bitmode", ret);
    ret = ftdi_set_bitmode(board->handle, 0, BITMODE_RESET);
    if (ret != 0) 
        exit_with_error(board->handle, "ftdi_set_bitmode", ret);
}


void set_chunk_size(board_t* board, int chunk_size) 
{
    int ret;
    ret = ftdi_write_data_set_chunksize(board->handle, chunk_size);
    if (ret != 0)
        exit_with_error(board->handle, 
                        "ftdi_write_data_set_chunksize", ret);
}

void send_buffer(board_t* board) 
{
    int ret;
    
    ret = ftdi_write_data(board->handle, board->send_buffer, 
                          board->send_buffer_index);
    if (ret != board->send_buffer_index) {
        fprintf(stderr, "ftdi_write_data returned wrong count. ");
        fprintf(stderr, "Expected %d. Returned: %d\n", 
                board->send_buffer_index, ret);
        exit(-1);
    }
    board->send_buffer_index = 0;
}


void send_command_impl(board_t* board, BYTE command, BYTE operand, 
                       BYTE send_immediately)
{
    
    if ((command > 13) || (command < 1)) {
        fprintf(stderr, "Command %d is not a valid command.\n", command);
        exit(-1);
    }
    if (operand > 15) {
        fprintf(stderr, "Operand %d is too large.\n", operand);
        exit(-1);
    }
    board->send_buffer[board->send_buffer_index++] = (command << 4) | operand;
    if (send_immediately || board->send_buffer_index >= SEND_BUFFER_SIZE) {
        send_buffer(board);
    }
}


void send_command_immediately(board_t* board, BYTE command, BYTE operand) 
{
    send_command_impl(board, command, operand, 1);
}


void send_command(board_t* board, BYTE command, BYTE operand)
{
    send_command_impl(board, command, operand, 0);
}


void set_panel_nums(board_t* board) 
{
    int ret, i;
    BYTE command, operand;
    BYTE read_buf[READ_BUFFER_SIZE];
    
    send_command_immediately(board, 1, 0); // Command 1 is Request Panel Nums

    printf("Board %s panels: [", board->serial_num);
    for (i=0; i<NUM_PANELS_PER_BOARD; ++i) {
        while (1) {
            ret = ftdi_read_data(board->handle, read_buf, READ_BUFFER_SIZE);
            if (ret < 0) 
                exit_with_error(board->handle, "ftdi_read_data", ret);
            if (ret == 1)
                break;
        }
        
        command = read_buf[0] >> 4;
        operand = read_buf[0] & 0x0f;
        if (command > 4) {
            fprintf(stderr, "Received invalid command: %d\n", command);
            exit(-1); 
        }
        printf("%d", operand);
        if (i < NUM_PANELS_PER_BOARD - 1) {
            printf(", ");
        }
        board->panel_nums[command-1] = operand;
    }
    printf("]\n");
}


void init_board(board_t* board, char* serial_num)
{
    int ret;
    
    board->handle = &(board->device_context);
    init_handle(board->handle);
    ret = ftdi_usb_open_desc(board->handle, VENDOR_ID, PRODUCT_ID,
                             DESCRIPTION_STRING, serial_num);
    if (ret != 0) 
        exit_with_error(board->handle, "ftdi_usb_open_desc", ret);
    strncpy(board->serial_num, serial_num, SERIAL_NUM_SIZE);
    ret = ftdi_usb_purge_buffers(board->handle);
    if (ret != 0) 
        exit_with_error(board->handle, "ftdi_usb_purge_buffers", ret);
    set_fpga_mode(board, FPGA_RESET);
    set_fpga_mode(board, FPGA_RUN);
    ret = ftdi_set_latency_timer(board->handle, 1);
    if (ret != 0)
        exit_with_error(board->handle, "ftdi_set_latency_timer", ret);
    set_panel_nums(board);
    board->send_buffer_index = 0;
    board->shmem = create_shared_mem();
}


void send_chunk_data(board_t* board, BYTE port_num, BYTE row_num, 
                     BYTE chunk_num, BYTE* data) 
{
    int i;
    BYTE command;
    
    if (port_num > NUM_PANELS_PER_BOARD -1) {
        fprintf(stderr, "Invalid port number: %u", port_num);
        exit(-1);
    }
    send_command(board, 2, port_num); 
    send_command(board, 3, row_num); 
    send_command(board, 4, chunk_num);
    
    for (i=0; i<NUM_NIBBLES_PER_CHUNK; ++i) {
        command = *(data+(i/2));
        if (i % 2) {
            command = (command & 0xf0) >> 4;
        } else {
            command = command & 0x0f;
        }
        send_command(board, i+5, command); // Send nibbles
    }
    
    send_command(board, 13, 0);  // Write chunk    
}


void send_row_data(board_t* board, BYTE port_num, BYTE row_num, BYTE* data) 
{
    int chunk_num;
    
    for (chunk_num=0; chunk_num<NUM_CHUNKS_PER_ROW; ++chunk_num) 
        send_chunk_data(board, port_num, row_num, chunk_num,
                        data+(chunk_num*NUM_BYTES_PER_CHUNK));
}


void send_panel_data(board_t* board, BYTE port_num, BYTE* data) 
{
    int row_num;
    
    for (row_num=0; row_num<NUM_ROWS; ++row_num) 
        send_row_data(board, port_num, row_num, 
                      data+(row_num*NUM_BYTES_PER_ROW));
}


void send_board_data(board_t* board)
{
    int port_num, panel_num;
    
    for (port_num=0; port_num<NUM_PANELS_PER_BOARD; ++port_num) {
        panel_num = board->panel_nums[port_num];
        send_panel_data(board, port_num, 
                        board->shmem+(panel_num*NUM_BYTES_PER_PANEL));
    }
}


long timevaldiff(struct timeval *starttime, struct timeval *finishtime)
{
    long msec;
    msec=(finishtime->tv_sec-starttime->tv_sec)*1000;
    msec+=(finishtime->tv_usec-starttime->tv_usec)/1000;
    return msec;
}


void* manage_board(void* serial_num)
{
    int reps = 10000;
    int i, ret;
    struct timeval start, end;
    float duration;
    board_t board;
    BYTE* shmem=NULL;
    
    init_board(&board, (char*) serial_num);
    while (1) {
        ret = gettimeofday(&start, NULL);
        for (i=0; i<reps; ++i) {
            send_board_data(&board);
        }
        ret = gettimeofday(&end, NULL);
        duration = timevaldiff(&start, &end) / 1000.0f;
        printf("Board# %s: %d frames in %.2f secs. %.2f fps.\n", 
               (char*) serial_num, reps, duration, reps / duration);
    }
    return NULL;
}


int detect_boards(char serial_nums[][SERIAL_NUM_SIZE]) 
{
    int i, board_num, ret;
    context device_context;
    context* handle;
    struct ftdi_device_list *devlist, *curdev;
    char description[DESCRIPTION_SIZE];
    char manufacturer[MANUFACTURER_SIZE];
    char serial_num[SERIAL_NUM_SIZE];

    handle = &device_context;
    init_handle(handle);
    
    ret = ftdi_usb_find_all(handle, &devlist, VENDOR_ID, PRODUCT_ID);
    if (ret < 0)
        exit_with_error(handle, "ftdi_usb_find_all", ret);
        
    i = 0;
    board_num = 0;
    for (curdev = devlist; curdev != NULL; i++)
    {
        ret = ftdi_usb_get_strings(
            handle, curdev->dev, manufacturer, MANUFACTURER_SIZE, 
            description, DESCRIPTION_SIZE, serial_num, SERIAL_NUM_SIZE);
        if (ret < 0)
            exit_with_error(handle, "ftdi_usb_get_strings", ret);
        if (strncmp(description, DESCRIPTION_STRING, DESCRIPTION_SIZE) == 0) {
            strncpy(serial_nums[board_num++], serial_num, SERIAL_NUM_SIZE);
        }
        curdev = curdev->next;
    }
 
    ftdi_list_free(&devlist);
    ftdi_deinit(handle);

    if (board_num > MAX_BOARDS) {
        fprintf(stderr, 
                "More than %d driver boards found. Exiting.\n", MAX_BOARDS);
        exit(-1);
    }
    return board_num;
}

void run_driver_threads(char serial_nums[][SERIAL_NUM_SIZE], int num_boards)
{
    int i;
    pthread_t threads[MAX_BOARDS];
    struct timespec t;
    
    t.tv_sec = 0;
    t.tv_nsec = 50e6;
    
    for (i=0; i<num_boards; ++i) {
        pthread_create(&threads[i], NULL, &manage_board, &serial_nums[i]);
        nanosleep(&t, NULL);
    }
    for (i=0; i<num_boards; ++i) {
        pthread_join(threads[i], NULL);
    }
}

int main()
{
    char serial_nums[MAX_BOARDS][SERIAL_NUM_SIZE];
    int num_boards;
    
    printf("Driver starting...\n");
    num_boards = detect_boards(serial_nums);
    printf("%d boards detected\n", num_boards);
    run_driver_threads(serial_nums, num_boards);
}

