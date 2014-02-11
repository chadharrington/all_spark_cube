import java.awt.Color;

import com.allsparkcube.CubeClient;


public class CubeDemo {
    public static void main(String[] args) {

        // final String HOST = "cube.ac";
        final String HOST = "localhost";
        final int PORT = 12345;
        
        CubeClient client = new CubeClient(HOST, PORT);

        // Set all LEDs to white
        client.setAllLeds(Color.white); 

         // Set the first LED to red
        client.setLed(0, Color.red);

        // Set the last LED to green
        client.setLed(4095, Color.green);

        // Starting at LED #48, set 16 LEDs to yellow
        client.setLedRange(48, 16, Color.yellow); 
        
        // Actually send the data to the cube
        client.send();  
        
        System.out.println("Success...");
    }
}
