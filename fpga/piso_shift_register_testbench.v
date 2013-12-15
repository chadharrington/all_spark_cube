`timescale 1ns / 10ps

module piso_shift_register_testbench;

   reg clk, reset_n, load_a, load_b, shift;
   reg [7:0] par_in_a, par_in_b;
   wire      ser_out;

   
   piso_shift_register uut
     (.clk(clk), .reset_n(reset_n), .par_in_a(par_in_a), .par_in_b(par_in_b),
      .load_a(load_a), .load_b(load_b), .shift(shift), .ser_out(ser_out));

   always begin  // 50MHz clock
      clk = 1'b1;
      #10;
      clk = 1'b0;
      #10;
   end

   initial begin
      load_a = 0;
      load_b = 0;
      par_in_a = 0;
      par_in_b = 0;
      shift = 0;
      reset_n = 0;
      #40;
      reset_n = 1;
      par_in_a = 8'b10101110;
      #20;
      load_a = 1;
      #20;
      load_a = 0;
      #20;
      shift = 1;
      #20;
      shift = 0;
      #20;
      shift = 1;
      #20;
      shift = 0;
      #20;
      shift = 1;
      #20;
      shift = 0;
      #20;
      shift = 1;
      #20;
      shift = 0;
      #20;
      shift = 1;
      #20;
      shift = 0;
      #20;
      shift = 1;
      #20;
      shift = 0;
      #20;
      shift = 1;
      #20;
      shift = 0;
      #20;
      shift = 1;
      #20;
      shift = 0;
      $stop;
   end // initial begin

endmodule // piso_testbench


