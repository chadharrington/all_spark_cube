#include "CubeInterface.h"

#include <thrift/protocol/TBinaryProtocol.h>
#include <thrift/server/TSimpleServer.h>
#include <thrift/transport/TServerSocket.h>
#include <thrift/transport/TBufferTransports.h>

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
        printf("Starting server...\n");
    }

    void set_data(const int16_t index, const std::vector<int16_t> & data) {
        if (data.size <= SHM_SIZE) {
            memmove(shmem + index, data.data(), data.size());
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
    server.serve();
    return 0;
}

