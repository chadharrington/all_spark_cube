
module rom
   (
    input clk,
    input [3:0] addr,
    output [7:0] data
   );
 
   reg [7:0] rom_data, data_reg;
 
   always @(posedge clk)
      data_reg <= rom_data;
  
   always @*
      case (addr)
         4'h0: rom_data = 8'b10000000;
         4'h1: rom_data = 8'b10000001;
         4'h2: rom_data = 8'b00000010;
         4'h3: rom_data = 8'b10000011;
         4'h4: rom_data = 8'b00000100;
         4'h5: rom_data = 8'b00000101;
         4'h6: rom_data = 8'b00000110;
         4'h7: rom_data = 8'b10000111;
         4'h8: rom_data = 8'b00001000;
         4'h9: rom_data = 8'b00001001;
         4'ha: rom_data = 8'b10001010;
         4'hb: rom_data = 8'b0001011;
         4'hc: rom_data = 8'b00001100;
         4'hd: rom_data = 8'b10001101;
         4'he: rom_data = 8'b00001110;
         4'hf: rom_data = 8'b10001111;
      endcase
  
   assign data = data_reg;

endmodule
