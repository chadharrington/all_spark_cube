
module rom
  (
   input       clk,
   input       reset_n,
   input [5:0] addr,
   output      load,
   output      shift,
   output      sclk,
   output      output_enable_n,
   output      latch_enable
   );
   
   reg [4:0]   rom_data, data_reg;
   
   always @(posedge clk, negedge reset_n)
     begin
        if (!reset_n)
          begin
             data_reg <= 5'b00010;
          end
        else
          begin
             data_reg <= rom_data;
          end
     end
   
   always @*
     begin
        case (addr)
          // data = load, shift, sclk, oe_n, le
          6'd00: rom_data = 5'b10000;
          6'd01: rom_data = 5'b00000;
          6'd02: rom_data = 5'b01100;
          6'd03: rom_data = 5'b00100;
          6'd04: rom_data = 5'b00000;
          6'd05: rom_data = 5'b01100;
          6'd06: rom_data = 5'b00100;
          6'd07: rom_data = 5'b00000;
          6'd08: rom_data = 5'b01100;
          6'd09: rom_data = 5'b00100;
          6'd10: rom_data = 5'b00000;
          6'd11: rom_data = 5'b01100;
          6'd12: rom_data = 5'b00100;
          6'd13: rom_data = 5'b00000;
          6'd14: rom_data = 5'b01100;
          6'd15: rom_data = 5'b00100;
          6'd16: rom_data = 5'b00000;
          6'd17: rom_data = 5'b01100;
          6'd18: rom_data = 5'b00100;
          6'd19: rom_data = 5'b00000;
          6'd20: rom_data = 5'b01100;
          6'd21: rom_data = 5'b00100;
          6'd22: rom_data = 5'b00000;
          6'd23: rom_data = 5'b01100;
          6'd24: rom_data = 5'b00100;
          6'd25: rom_data = 5'b00000; // Data clocked in
          6'd26: rom_data = 5'b01100;
          6'd27: rom_data = 5'b00100;
          6'd28: rom_data = 5'b00000;
          6'd29: rom_data = 5'b01100;
          6'd30: rom_data = 5'b00100;
          6'd31: rom_data = 5'b00000;
          6'd32: rom_data = 5'b01100;
          6'd33: rom_data = 5'b00100;
          6'd34: rom_data = 5'b00000;
          6'd35: rom_data = 5'b01100;
          6'd36: rom_data = 5'b00100;
          6'd37: rom_data = 5'b00000;
          6'd38: rom_data = 5'b01100;
          6'd39: rom_data = 5'b00100;
          6'd40: rom_data = 5'b00000;
          6'd41: rom_data = 5'b01100;
          6'd42: rom_data = 5'b00100;
          6'd43: rom_data = 5'b00000;
          6'd44: rom_data = 5'b01100;
          6'd45: rom_data = 5'b00100;
          6'd46: rom_data = 5'b00000;
          6'd47: rom_data = 5'b00100;
          6'd48: rom_data = 5'b00100;
          6'd49: rom_data = 5'b00000; // Data clocked in
          6'd50: rom_data = 5'b00001; // Data latched
          6'd51: rom_data = 5'b00001;
          6'd52: rom_data = 5'b00001;
          6'd53: rom_data = 5'b00001;
          6'd54: rom_data = 5'b00000;
          6'd55: rom_data = 5'b00000;
          6'd56: rom_data = 5'b00000;
          6'd57: rom_data = 5'b00000;
          6'd58: rom_data = 5'b00000;
          6'd59: rom_data = 5'b00000;
          6'd60: rom_data = 5'b00000;
          6'd61: rom_data = 5'b00000;
          6'd62: rom_data = 5'b00000;
          6'd63: rom_data = 5'b00000;
        endcase // case (addr)
     end // always @ *
   
   
   assign load = data_reg[4];
   assign shift = data_reg[3];
   assign sclk = data_reg[2];
   assign output_enable_n = data_reg[1];
   assign latch_enable = data_reg[0];


endmodule
