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

   wire [15:0]   row_select_n;
   wire          clk;
   wire          reset_n;
   

   controller cont
     (.clk(clk), 
      .reset_n(reset_n), 
      .serial_clk(GPIO_0[0]), 
      .latch_enable(GPIO_0[1]), 
      .output_enable_n(GPIO_0[2]), 
      .serial_data_out_red({GPIO_0[8], GPIO_0[9], GPIO_0[10], GPIO_0[11]}),
      .serial_data_out_green({GPIO_0[16], GPIO_0[17], GPIO_0[18], GPIO_0[19]}),
      .serial_data_out_blue({GPIO_0[24], GPIO_0[25], GPIO_0[26], GPIO_0[27]}),
      .row_select_n(row_select_n)
      );

   // Resets are active low, ANDing them provides OR behavior
   assign reset_n = KEY[0] & GPIO_2[11];
   assign clk = CLOCK_50;
   assign GPIO_1[15:0] = row_select_n;
   
   assign LED = row_select_n[7:0];
   
   
endmodule
