import java.awt.Color;

import com.allsparkcube.CubeClient;


public class HelloWorld {
    public static void main(String[] args) {
        try {

            // final String HOST = "localhost";
            final String HOST = "cube.ac";
            final int PORT = 12345;
        
            CubeClient client = new CubeClient(HOST, PORT);

            // Set all LEDs to blue
            client.setAllLeds(Color.white); 

            // Set the first LED (#0) to red
            client.setLed(0, Color.red);

            // Set the second LED (#1) to a custom color (teal-ish)
            Color teal = new Color(100, 255, 95);
            client.setLed(1, teal);
        
            // Starting at LED #48, set 16 LEDs to yellow
            client.setLedRange(48, 16, Color.yellow); 

            // Set the last LED (#4095) to green
            client.setLed(4095, Color.green);
        
            // Actually send the data to the cube
            client.send();  
        
            System.out.println("Success...");
        } catch (TException e) {
            e.printStackTrace();
        }
    }
}

