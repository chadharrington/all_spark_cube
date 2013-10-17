module cube_controller
  (
   input        CLOCK_50, // Reference clock   
   input [1:0]  KEY,
   input [3:0]  SW,
   inout [12:0] GPIO_2,
   input [2:0]  GPIO_2_IN,
   inout [33:0] GPIO_0,
   input [1:0]  GPIO_0_IN,
   inout [33:0] GPIO_1,
   input [1:0]  GPIO_1_IN,
   output [7:0] LED
   );

   wire [7:0]   led_vals, brightness;
   wire         clk, reset_n;
   wire         serial_clk, latch_enable, output_enable_n;
   wire [15:0]  row_select_n;
   wire         test_panel_select_n;
   
   
   // Resets are active low, ANDing them provides OR behavior
   assign reset_n = KEY[0] & GPIO_2[11];
   assign clk = CLOCK_50;

   // TODO: Remove these debugging lines and corresponding controller outputs
   assign GPIO_1[15:0] = row_select_n;
   assign GPIO_0[0] = serial_clk;
   assign GPIO_0[1] = latch_enable;
   assign GPIO_0[2] = output_enable_n;
   assign GPIO_1[15:0] = row_select_n;
   assign LED = {row_select_n[4:0], serial_clk, output_enable_n, latch_enable};

   // TODO: Assign test_panel_select_n to GPIO_1[33]
   assign test_panel_select_n = 1'b0;
   //assign test_panel_select_n = GPIO_1[33];
   
   
   controller cont
     (.clk(clk), 
      .reset_n(reset_n),
      .test_panel_select_n(test_panel_select_n),
      .serial_clk(serial_clk), 
      .latch_enable(latch_enable), 
      .output_enable_n(output_enable_n),
      // Note that the port numbers here are different from the schematic
      // in order to compensate for the PCB layout placement errors
      .serial_data_out({GPIO_0[27], GPIO_0[26], GPIO_0[11], // Panel 3
                        GPIO_0[25], GPIO_0[24], GPIO_0[10], // Panel 2
                        GPIO_0[16], GPIO_0[19], GPIO_0[9],  // Panel 1
                        GPIO_0[18], GPIO_0[17], GPIO_0[8]}),// Panel 0
      .row_select_n(row_select_n)
      );

endmodule
