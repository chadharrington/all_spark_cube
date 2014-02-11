package com.allsparkcube;

import java.util.Arrays;

import org.apache.thrift.TException;
import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransport;
import org.apache.thrift.transport.TTransportException;

public class CubeClient {

    public static void main(String[] args) {

        try {
            TTransport transport;

            transport = new TSocket("localhost", 12345);
            transport.open();
            TProtocol protocol = new TBinaryProtocol(transport);
            CubeInterface.Client client = new CubeInterface.Client(protocol);
            Short[] buffer = new Short[4096];
            
            client.set_data(Arrays.asList(buffer));
            System.out.println("Success.");

            transport.close();
        } catch (TTransportException e) {
            e.printStackTrace();
        } catch (TException x) {
            x.printStackTrace();
        }
    }
}
