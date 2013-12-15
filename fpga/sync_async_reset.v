// This code is based on the Synchronized Asynchronous Reset from:
//  Quartus II Handbook Version 13.0
//  Volume 1: Design and Synthesis
//  Chapter 13: Recommended Design Practices
//  Figure 13-20 & Example 13-11

module sync_async_reset 
  (
   input  clk,
   input  reset_n,
   output synced_reset_n
  );
   
   reg    reg3, reg4;
   
   assign synced_reset_n = reg4;
   
   always @ (posedge clk, negedge reset_n)
     begin
        if (!reset_n)
          begin
             reg3 <= 1'b0;
             reg4 <= 1'b0;
          end
        else
          begin
             reg3 <= 1'b1;
             reg4 <= reg3;
          end
     end 
   
endmodule 
