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

   controller cont
     (.clk(CLOCK_50), .reset_n(KEY[0]), .led_vals(led_vals), 
      .brightness(brightness), .serial_clk(GPIO_0[7]), 
      .serial_out(GPIO_0[6]), .output_enable_n(GPIO_0[5]),
      .latch_enable(GPIO_0[4]));

   assign led_vals = {SW, SW};
   assign LED = led_vals;
   assign brightness = 8'hff;
   //assign color = 8'd0;
   //assign color = 8'hff;
   //assign brightness = 8'b10101010;

endmodule


