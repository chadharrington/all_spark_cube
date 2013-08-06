`timescale 1ns / 10ps

module inverting_decoder_testbench;

   reg [3:0] addr;
   wire [15:0] y_n;
   
   inverting_decoder uut
     (.addr(addr), .y_n(y_n));

   initial begin
      addr = 4'd0;
      #10;
      addr = 4'd1;
      #10;
      addr = 4'd2;
      #10;
      addr = 4'd3;
      #10;
      addr = 4'd4;
      #10;
      addr = 4'd5;
      #10;
      addr = 4'd6;
      #10;
      addr = 4'd7;
      #10;
      addr = 4'd8;
      #10;
      addr = 4'd9;
      #10;
      addr = 4'd10;
      #10;
      addr = 4'd11;
      #10;
      addr = 4'd12;
      #10;
      addr = 4'd13;
      #10;
      addr = 4'd14;
      #10;
      addr = 4'd15;
      #10;
      $stop;
   end // initial begin

endmodule // inverting_decoder_testbench

      
        
   
