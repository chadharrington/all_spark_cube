#include <errno.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>

#include "shmem.h"

#define SHM_PERMS 0666 | IPC_CREAT
#define MSG_SIZE 4096*3
#define PORT 12345
#define INIT_FILENAME "/opt/adaptive/cube/initialization.bin"

long timevaldiff(struct timeval *starttime, struct timeval *finishtime)
{
    long msec;
    msec=(finishtime->tv_sec-starttime->tv_sec)*1000;
    msec+=(finishtime->tv_usec-starttime->tv_usec)/1000;
    return msec;
}

int get_udp_socket()
{
    int sockfd, optval;
    struct sockaddr_in servaddr;

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        fprintf(stderr, "Error opening UDP socket for listening.\n");
        exit(-1);
    }
    
    /* setsockopt: Handy debugging trick that lets 
     * us rerun the server immediately after we kill it; 
     * otherwise we have to wait about 20 secs. 
     * Eliminates "ERROR on binding: Address already in use" error. 
     */
    optval = 1;
    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, 
	       (const void * ) &optval, sizeof(int));

    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(PORT);
    bind(sockfd, (struct sockaddr *) &servaddr, sizeof(servaddr));
    return sockfd;
}

void init_cube(BYTE* shmem) 
{
    FILE* initfile;
    initfile = fopen(INIT_FILENAME, "r");
    if (initfile == NULL) {
        fprintf(stderr, "Can't open initialization file %s\n", INIT_FILENAME);
        exit(-1);
    }
    fread(shmem, sizeof(BYTE), MSG_SIZE, initfile);
    fclose(initfile);
}

void serve(BYTE* shmem, int sockfd) 
{
    int i, recvlen, ret;
    int reps = 10000;
    BYTE msg[MSG_SIZE];
    struct timeval start, end;
    float duration;
    struct sockaddr_in cliaddr;
    socklen_t addrlen;

    addrlen = sizeof(cliaddr);
    printf("Starting server...\n");
    while (1) {
        ret = gettimeofday(&start, NULL);
        for (i=0; i<reps; ++i) {
            recvlen = recvfrom(sockfd, msg, MSG_SIZE, 0, 
                               (struct sockaddr *) &cliaddr, &addrlen);
            if (recvlen == MSG_SIZE) {
                memcpy(shmem, msg, MSG_SIZE);
            }
        }
        ret = gettimeofday(&end, NULL);
        duration = timevaldiff(&start, &end) / 1000.0f;
        printf("%d frames in %.2f secs. %.2f fps.\n", 
               reps, duration, reps / duration);
    }    
}

int main(int argc, char**argv)
{
    BYTE* shmem;
    int sockfd;

    shmem = get_shared_mem(SHM_PERMS);
    init_cube(shmem);
    sockfd = get_udp_socket();
    serve(shmem, sockfd);
    
    return 0;
}
