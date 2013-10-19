module synchronizer
  #(parameter WIDTH=1)
  (
   input              clk,
   input              reset_n,
   input  [WIDTH-1:0] in,
   output [WIDTH-1:0] out
   );

   wire [WIDTH-1:0]   ff1_out;

   register #(.WIDTH(WIDTH)) ff1
     (.clk(clk), .reset_n(reset_n), .d(in), .q(ff1_out));

   register #(.WIDTH(WIDTH)) ff2
     (.clk(clk), .reset_n(reset_n), .d(ff1_out), .q(out));

endmodule // synchronizer
