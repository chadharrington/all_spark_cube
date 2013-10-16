
module synchronous_two_input_multiplexer
  #(parameter WIDTH=16)
   (
    input                  clk,
    input                  select,
    input      [WIDTH-1:0] in0,
    input      [WIDTH-1:0] in1,
    output reg [WIDTH-1:0] out
    );

   always @(posedge clk)
     case (select)
       1'b0: out = in0;
       1'b1: out = in1;
     endcase // case (select)

endmodule // synchronous_two_input_multiplexer
