#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <ftdi.h> 

#define SHM_KEY 1278899529
#define SHM_SIZE 12288
#define SHM_PERMS 0444
#define MAX_BOARDS 10
#define NUM_PANELS_PER_BOARD 4
#define SEND_BUFFER_SIZE 1000

/* FTDI Constants */
#define SERIAL_SIZE 17
#define DESCRIPTION_STRING "Cube Driver Board"
#define DESCRIPTION_SIZE 64
#define MANUFACTURER_SIZE 64
#define VENDOR_ID 0403
#define PRODUCT_ID 6014


void* run(void* serial_num)
{
    
    printf("run: %s\n", (char*) serial_num);

    return NULL;
}


int detect_boards(char serial_nums[][SERIAL_SIZE]) 
{
    int i, board_num, ret;
    struct ftdi_context ftdi;
    struct ftdi_device_list *devlist, *curdev;
    char description[DESCRIPTION_SIZE];
    char manufacturer[MANUFACTURER_SIZE];
    char serial[SERIAL_SIZE];
    
 
    ret = ftdi_init(&ftdi);
    if (ret != 0)
    {
        fprintf(stderr, "ftdi_init failed:%d\n", ret);
        exit(-1);
    }
    
    ret = ftdi_usb_find_all(&ftdi, &devlist, VENDOR_ID, PRODUCT_ID);
    if (ret < 0)
    {
        fprintf(stderr, "ftdi_usb_find_all failed: %d (%s)\n", ret, 
                ftdi_get_error_string(&ftdi));
        exit(-1);
    }
    
        
 
    i = 0;
    board_num = 0;
    for (curdev = devlist; curdev != NULL; i++)
    {
        printf("Checking device: %d\n", i);
        ret = ftdi_usb_get_strings(
            &ftdi, curdev->dev, manufacturer, MANUFACTURER_SIZE, 
            description, DESCRIPTION_SIZE, serial, SERIAL_SIZE);
        if (ret < 0)
        {
            fprintf(stderr, "ftdi_usb_get_strings failed: %d (%s)\n", ret, 
                    ftdi_get_error_string(&ftdi));
            exit(-1);
        }
        if (strncmp(description, DESCRIPTION_STRING, DESCRIPTION_SIZE) == 0) {
            strncpy(serial_nums[board_num++], serial, SERIAL_SIZE);
        }
        curdev = curdev->next;
    }
 
    ftdi_list_free(&devlist);
    ftdi_deinit(&ftdi);

    if (board_num > MAX_BOARDS) {
        fprintf(stderr, 
                "More than %d driver boards found. Exiting.\n", MAX_BOARDS);
        exit(-1);
    }
    return board_num;
}

void run_driver_threads(char serial_nums[][SERIAL_SIZE], int num_boards)
{
    int i;
    pthread_t threads[MAX_BOARDS];
    
    for (i=0; i<num_boards; ++i) {
        /* printf("%s\n", serial_nums[i]); */
        pthread_create(&threads[i], NULL, &run, &serial_nums[i]);
    }
    for (i=0; i<num_boards; ++i) {
        pthread_join(threads[i], NULL);
    }

}

int main()
{
    char serial_nums[MAX_BOARDS][SERIAL_SIZE];
    int num_boards;
    
    printf("Driver starting...\n");
    num_boards = detect_boards(serial_nums);
    run_driver_threads(serial_nums, num_boards);
}

