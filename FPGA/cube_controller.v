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
   wire         reset_n;
   // For debugging
   wire         sclk, le, oe_n, sdo0;
   wire [15:0]  row_n;
   
   controller cont
     (.clk(CLOCK_50), 
      .reset_n(reset_n),
      .switches(SW),
      .serial_clk(sclk), 
      .latch_enable(le), 
      .output_enable_n(oe_n), 
      .serial_data_out_0_red(sdo0),
      .serial_data_out_1_red(GPIO_0[9]),
      .serial_data_out_2_red(GPIO_0[10]),
      .serial_data_out_3_red(GPIO_0[11]),
      .serial_data_out_0_green(GPIO_0[16]),
      .serial_data_out_1_green(GPIO_0[17]),
      .serial_data_out_2_green(GPIO_0[18]),
      .serial_data_out_3_green(GPIO_0[19]),
      .serial_data_out_0_blue(GPIO_0[24]),
      .serial_data_out_1_blue(GPIO_0[25]),
      .serial_data_out_2_blue(GPIO_0[26]),
      .serial_data_out_3_blue(GPIO_0[27]),
      .row_select_n(row_n)
      );

   // Resets are active low, ANDing them provides OR behavior
   //assign reset_n = KEY[0] & GPIO_2[11];
   assign reset_n = KEY[0];
   assign GPIO_0[0] = sclk;
   assign GPIO_0[1] = le;
   assign GPIO_0[2] = oe_n;
   assign GPIO_0[8] = sdo0;
   assign GPIO_1[15:0] = row_n;
   
   assign LED = {row_n[3:0], sclk, oe_n, le, sdo0};
      
   
endmodule


