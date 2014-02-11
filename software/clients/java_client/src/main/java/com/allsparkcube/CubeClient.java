package com.allsparkcube;

import java.awt.Color;
import java.util.Arrays;
import java.util.List;

import org.apache.thrift.TException;
import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransport;
import org.apache.thrift.transport.TTransportException;


public class CubeClient {

    TTransport transport;
    TProtocol protocol;
    CubeInterface.Client client;
    Short[] buffer;
        
    public CubeClient(String host, int port) {
        transport = new TSocket(host, port);
        buffer = new Short[12288];
        Short defaultValue = 0;
        Arrays.fill(buffer, defaultValue);
    }

    public void setLed(int ledNum, Color color) {
        buffer[ledNum * 3] = (short) color.getRed();
        buffer[ledNum * 3 + 1] = (short) color.getGreen();
        buffer[ledNum * 3 + 2] = (short) color.getBlue();
    }

    public void setLedRange(int ledNumStart, int numLeds, Color color) {
        for(int i=ledNumStart; i < ledNumStart + numLeds; i++) {
            setLed(i, color);
        }
    }

    public void setAllLeds(Color color) {
        setLedRange(0, 4096, color);
    }

    public void send() {
        try {
            transport.open();
            protocol = new TBinaryProtocol(transport);
            client = new CubeInterface.Client(protocol);
            client.set_data(Arrays.asList(buffer));
        } catch (TTransportException e) {
            e.printStackTrace();
        } catch (TException x) {
            x.printStackTrace();
        } finally {
            transport.close();
        }
    }
}

