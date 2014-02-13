import java.awt.Color;

import com.allsparkcube.CubeClient;


public class HelloWorld {
    public static void main(String[] args) {

        // final String HOST = "localhost";
        final String HOST = "cube.ac";
        final int PORT = 12345;
        
        CubeClient client = new CubeClient(HOST, PORT);

        // Set all LEDs to white
        client.setAllLeds(Color.white); 

         // Set the first LED (#0) to red
        client.setLed(0, Color.red);

        // Set the last LED (#4095) to green
        client.setLed(4095, Color.green);

        // Set the second LED (#1) to a custom color (purple-ish)
        client.setLed(1, Color(204, 153, 255));
        
        // Starting at LED #48, set 16 LEDs to yellow
        client.setLedRange(48, 16, Color.yellow); 
        
        // Actually send the data to the cube
        client.send();  
        
        System.out.println("Success...");
    }
}
