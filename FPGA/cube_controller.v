module cube_controller
  #(parameter COUNTER_WIDTH=32)
  (
   input        CLOCK_50, // Reference clock
   output [7:0] LED,
   input [1:0] KEY,
   input [3:0] SW,
   inout [12:0] GPIO_2,
   input [2:0] GPIO_2_IN,
   inout [33:0] GPIO_0,
   input [1:0] GPIO_0_IN,
   inout [33:0] GPIO_1,
   input [1:0] GPIO_1_IN
   );

   wire global_reset_n;
   wire [COUNTER_WIDTH-1:0] counter_val;
   
   sync_async_reset reset_block 
     (.clk(CLOCK_50), .reset_n(KEY[0]), .synced_reset_n(global_reset_n));
   binary_counter #(.N(COUNTER_WIDTH)) counter
     (.clk(CLOCK_50), .reset_n(global_reset_n), .count(counter_val));
   rom control_rom 
     (.clk(CLOCK_50), .addr(counter_val[28:25]), .data(GPIO_0[7:0]));
   
   assign LED = SW;
   
endmodule


