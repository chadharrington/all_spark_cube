
module decoder
  #(parameter WIDTH=4)
  (
   input [WIDTH-1:0]   addr,
   output [2**WIDTH-1:0] y
   );

   assign y = 1'b1 << addr;

endmodule
