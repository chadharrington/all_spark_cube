
module inverting_decoder
  (
   input [3:0]   addr,
   output [15:0] y_n
   );

   assign y_n = ~(1 << addr);

endmodule
