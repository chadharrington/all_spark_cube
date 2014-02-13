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

/**
 * This class interfaces with the All Spark Cube over the network. 
 * Calling any of the set* methods modifies the internal buffer. 
 * To actually update the cube, a program must call the send() method,
 * which then sends the  current buffer to the cube.
 *
 * @author Chad Harrington
 * 
 */
public class CubeClient {

    TTransport transport;
    TProtocol protocol;
    CubeInterface.Client client;
    Short[] buffer;
        
/**
 * Creates a client object connected to the cube on the given
 * host and port.
 * @param host the network hostname or address of the cube
 * @param port the port number the cube is listening on
 */
    public CubeClient(String host, int port) {
        transport = new TSocket(host, port);
        buffer = new Short[12288];
        Short defaultValue = 0;
        Arrays.fill(buffer, defaultValue);
    }

/**
 * Sets the color of single LED in the internal buffer. No changes
 * are reflected on the cube until the send() method is called.
 * @param ledNum the number of the LED [0..4095]
 * @param color the color to set
 */
    public void setLed(int ledNum, Color color) {
        buffer[ledNum * 3] = (short) color.getRed();
        buffer[ledNum * 3 + 1] = (short) color.getGreen();
        buffer[ledNum * 3 + 2] = (short) color.getBlue();
    }

/**
 * Sets the color of a range of LEDs in the internal buffer. No changes
 * are reflected on the cube until the send() method is called.
 * @param ledNumStart the number of the first LED [0..4095] in the
 * range
 * @param numLeds the number of LEDs in the range
 * @param color the color to set
 */
    public void setLedRange(int ledNumStart, int numLeds, Color color) {
        for(int i=ledNumStart; i < ledNumStart + numLeds; i++) {
            setLed(i, color);
        }
    }

/**
 * Sets the color of all the LEDs in the internal buffer. No changes
 * are reflected on the cube until the send() method is called.
 * @param color the color to set
 */
    public void setAllLeds(Color color) {
        setLedRange(0, 4096, color);
    }

/**
 * Sends the internal buffer to the cube. When this method is called,
 * the cube will be updated to match the colors stored in the
 * internal buffer.
*/
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

