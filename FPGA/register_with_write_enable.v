module register_with_write_enable
  #(parameter WIDTH = 1)
   (
    input                  clk,
    input                  reset_n,
    input                  write_enable,
    input      [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
    );

   always @(posedge clk, negedge reset_n)
     if (!reset_n)
       q <= {WIDTH {1'b0}};
     else
       if (write_enable)
         q <= d;

endmodule // register
