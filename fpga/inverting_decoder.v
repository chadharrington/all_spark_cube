
module inverting_decoder
  #(parameter WIDTH=4)
  (
   input [WIDTH-1:0]   addr,
   output [2**WIDTH-1:0] y_n
   );

   assign y_n = ~(1'b1 << addr);

endmodule
