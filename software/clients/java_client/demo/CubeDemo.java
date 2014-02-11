import java.awt.Color;

import com.allsparkcube.CubeClient;


public class CubeDemo {
    public static void main(String[] args) {

        final String HOST = "cube.ac";
        final int PORT = 12345;
        
        CubeClient client = new CubeClient(HOST, PORT);
        
        client.setColor(0, Color.red); // Set the first LED to red
        client.setColor(4095, Color.green); // Set the last LED to green
        client.send();  // Actually send the data to the cube
    }
}
