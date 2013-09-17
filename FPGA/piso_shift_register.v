module piso_shift_register
  #(parameter WIDTH=8)
   (
    input             clk,
    input             reset_n, 
    input [WIDTH-1:0] par_in_a, 
    input [WIDTH-1:0] par_in_b,
    input             load_a, 
    input             load_b,
    input             shift,
    output            ser_out
   );

   reg [WIDTH-1:0] data_reg;
   integer         i;
   
   always @(posedge clk, negedge reset_n)
     if (!reset_n)
       data_reg <= {WIDTH {1'b0}};
     else
       if (load_a)
         data_reg <= par_in_a;
       else
         if (load_b)
           data_reg <= par_in_b;
         else
           if (shift)
             begin
                for (i=0; i<WIDTH-1; i=i+1)
                  data_reg[i+1] <= data_reg[i];
                data_reg[0] <= 0;
             end

      
   assign ser_out = data_reg[WIDTH-1];

endmodule

   
