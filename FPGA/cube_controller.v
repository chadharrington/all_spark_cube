module cube_controller
  (
   input        CLOCK_50, // Reference clock
   output [7:0] LED,
   input [1:0] KEY,
   input [3:0] SW,
   inout [12:0] GPIO_2,
   input [2:0] GPIO_2_IN,
   inout [33:0] GPIO_0,
   input [1:0] GPIO_0_IN,
   inout [33:0] GPIO_1,
   input [1:0] GPIO_1_IN
   );


   assign LED[0] = SW[0] & SW[1];
   assign LED[1] = SW[0] | SW[1];
   assign GPIO_0[3:0] = SW[3:0];
   
endmodule


