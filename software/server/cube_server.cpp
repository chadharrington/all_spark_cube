#include "CubeInterface.h"

#include <thrift/protocol/TBinaryProtocol.h>
#include <thrift/server/TSimpleServer.h>
#include <thrift/transport/TServerSocket.h>
#include <thrift/transport/TBufferTransports.h>

using namespace ::apache::thrift;
using namespace ::apache::thrift::protocol;
using namespace ::apache::thrift::transport;
using namespace ::apache::thrift::server;

using boost::shared_ptr;

class CubeInterfaceHandler : virtual public CubeInterfaceIf {
 public:
  CubeInterfaceHandler() {
    // Your initialization goes here
  }

  void set_data(const int16_t index, const std::vector<int16_t> & data) {
    // Your implementation goes here
    printf("set_data\n");
  }

};

int main(int argc, char **argv) {
  int port = 12345;
  shared_ptr<CubeInterfaceHandler> handler(new CubeInterfaceHandler());
  shared_ptr<TProcessor> processor(new CubeInterfaceProcessor(handler));
  shared_ptr<TServerTransport> serverTransport(new TServerSocket(port));
  shared_ptr<TTransportFactory> transportFactory(new TBufferedTransportFactory());
  shared_ptr<TProtocolFactory> protocolFactory(new TBinaryProtocolFactory());

  TSimpleServer server(processor, serverTransport, transportFactory, protocolFactory);
  server.serve();
  return 0;
}

