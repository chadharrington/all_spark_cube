
module binary_counter
  #(parameter N=8)
   (
    input clk,
    input reset_n,
    output [N-1:0] count
   );

   reg [N-1:0]     count_reg;
   wire [N-1:0]    next_count;

   always @(posedge clk, negedge reset_n)
     if (!reset_n)
       count_reg <= 0;
     else
       count_reg <= next_count;

   assign next_count = count_reg + 1;
   assign count = count_reg;

endmodule // binary_counter

