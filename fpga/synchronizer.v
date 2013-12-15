module synchronizer
  #(parameter WIDTH=1)
  (
   input              clk,
   input  [WIDTH-1:0] in,
   output [WIDTH-1:0] out
   );

   wire [WIDTH-1:0]   ff1_out;

   register_without_reset #(.WIDTH(WIDTH)) ff1
     (.clk(clk), .d(in), .q(ff1_out));

   register_without_reset #(.WIDTH(WIDTH)) ff2
     (.clk(clk), .d(ff1_out), .q(out));

endmodule // synchronizer
