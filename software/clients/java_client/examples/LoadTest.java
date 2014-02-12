import java.awt.Color;

import com.allsparkcube.CubeClient;


public class LoadTest {
    public static void main(String[] args) {

        final String HOST = "localhost";
        final int PORT = 12345;
        final int reps = 1500;
        
        CubeClient client = new CubeClient(HOST, PORT);
        
        client.setAllLeds(Color.orange); 
        client.setLed(0, Color.green); 

        
        while (true) {
            long startTime = System.currentTimeMillis();
            for (int i=0; i < reps; i++) {
                client.send();  // Actually send the data to the cube
            }
            float duration = (System.currentTimeMillis() - startTime) / 1000.0f;
            float fps = reps / duration;
            System.out.printf("%d frames in %.2f secs. (%.2f fps)\n",
                              reps, duration, fps);
        }
    }
}
