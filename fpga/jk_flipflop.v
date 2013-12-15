module jk_flipflop
  (
   input      clk,
   input      reset_n,
   input      j,
   input      k,
   output reg q
   );

   always @(posedge clk, negedge reset_n)
     if (!reset_n)
       q <= 1'b0;
     else
       q <= (j & ~q) | (~k & q);

endmodule // jk_flipflop
