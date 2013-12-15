`timescale 1ns / 10ps

module controller_testbench;

   reg clk, reset_n;
   wire serial_clk, output_enable_n, latch_enable;
   wire [3:0] serial_data_out_red;
   wire [3:0] serial_data_out_green;
   wire [3:0] serial_data_out_blue;
   wire [15:0] row_select_n;
   

   controller uut
     (.clk(clk), .reset_n(reset_n), .serial_clk(serial_clk),
      .latch_enable(latch_enable), .output_enable_n(output_enable_n),
      .serial_data_out_red(serial_data_out_red), 
      .serial_data_out_green(serial_data_out_green),
      .serial_data_out_blue(serial_data_out_blue),
      .row_select_n(row_select_n));
   

   always begin  // 50MHz clock
      clk = 1'b1;
      #10;
      clk = 1'b0;
      #10;
   end

   initial begin
      clk = 0;
      reset_n = 0;
      #40;
      reset_n = 1;
      #1000;
      $stop;
   end
   
endmodule // cube_controller_testbench
