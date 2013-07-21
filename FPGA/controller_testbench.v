`timescale 1ns / 10ps

module controller_testbench;

   reg clk, reset_n;
   wire [7:0] led_vals, brightness;
   wire      serial_clk, serial_out, output_enable_n, latch_enable;

   controller uut
     (.clk(clk), .reset_n(reset_n), .led_vals(led_vals), 
      .brightness(brightness), .serial_clk(serial_clk),
      .serial_out(serial_out), .output_enable_n(output_enable_n),
      .latch_enable(latch_enable));

   assign led_vals = 8'b10101110;
   assign brightness = 8'b00110011;

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
