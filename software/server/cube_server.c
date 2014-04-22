#include <errno.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>

#include "shmem.h"

#define SHM_PERMS 0666 | IPC_CREAT
#define MSG_SIZE 4096*3
#define PORT 12345


int main(int argc, char**argv)
{
    int sockfd, recvlen, optval;
    struct sockaddr_in servaddr, cliaddr;
    socklen_t addrlen;
    BYTE msg[MSG_SIZE];
    BYTE* shmem;

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
    addrlen = sizeof(cliaddr);
    shmem = get_shared_mem(SHM_PERMS);

    printf("Starting server...\n");
    while (1) {

        recvlen = recvfrom(sockfd, msg, MSG_SIZE, 0, 
                           (struct sockaddr *) &cliaddr, &addrlen);
        printf("recvlen: %d\n", recvlen);
        if (recvlen == MSG_SIZE) {
            memcpy(shmem, msg, MSG_SIZE);
        }
    }
}
