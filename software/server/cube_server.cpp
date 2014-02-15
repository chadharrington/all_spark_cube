#include <iostream>
#include <fstream>

#include <thrift/protocol/TBinaryProtocol.h>
#include <thrift/server/TSimpleServer.h>
#include <thrift/transport/TServerSocket.h>
#include <thrift/transport/TBufferTransports.h>

#include "CubeInterface.h"
#include "shmem.h"

using namespace ::apache::thrift;
using namespace ::apache::thrift::protocol;
using namespace ::apache::thrift::transport;
using namespace ::apache::thrift::server;
using boost::shared_ptr;

#define SHM_PERMS 0666 | IPC_CREAT


class CubeInterfaceHandler : virtual public CubeInterfaceIf {
    BYTE* shmem;
public:
    CubeInterfaceHandler() {
        shmem = get_shared_mem(SHM_PERMS);
        std::ifstream initfile("/opt/adaptive/cube/initialization.bin", 
                          std::ios::binary | std::ios::in);
        initfile.read((char*)shmem, SHM_SIZE);
        initfile.close();
    }

    void set_data(const std::vector<int16_t> & data) {
        if (data.size() == SHM_SIZE) {
            for (unsigned int i=0; i<SHM_SIZE; ++i) {
                *(shmem + i) = (unsigned char) data[i];
            }
        }
    }

};

int main(int argc, char **argv) {
    int port = 12345;
    shared_ptr<CubeInterfaceHandler> handler(new CubeInterfaceHandler());
    shared_ptr<TProcessor> processor(new CubeInterfaceProcessor(handler));
    shared_ptr<TServerTransport> serverTransport(new TServerSocket(port));
    shared_ptr<TTransportFactory> transportFactory(
        new TBufferedTransportFactory());
    shared_ptr<TProtocolFactory> protocolFactory(new TBinaryProtocolFactory());
    TSimpleServer server(processor, serverTransport, transportFactory, 
                         protocolFactory);
    printf("Starting server...\n");
    server.serve();
    return 0;
}

