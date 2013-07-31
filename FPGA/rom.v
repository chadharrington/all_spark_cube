
module rom
  (
   input       clk,
   input       reset_n,
   input [6:0] addr,
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
          7'd000: rom_data = 5'b10000;
          7'd001: rom_data = 5'b00000;
          7'd002: rom_data = 5'b01100;
          7'd003: rom_data = 5'b00000;
          7'd004: rom_data = 5'b01100;
          7'd005: rom_data = 5'b00000;
          7'd006: rom_data = 5'b01100;
          7'd007: rom_data = 5'b00000;
          7'd008: rom_data = 5'b01100;
          7'd009: rom_data = 5'b00000;
          7'd010: rom_data = 5'b01100;
          7'd011: rom_data = 5'b00000;
          7'd012: rom_data = 5'b01100;
          7'd013: rom_data = 5'b00000;
          7'd014: rom_data = 5'b01100;
          7'd015: rom_data = 5'b00000;
          7'd016: rom_data = 5'b01100;
          7'd017: rom_data = 5'b00000; // Data clocked in
          7'd018: rom_data = 5'b01100;
          7'd019: rom_data = 5'b00000;
          7'd020: rom_data = 5'b01100;
          7'd021: rom_data = 5'b00000;
          7'd022: rom_data = 5'b01100;
          7'd023: rom_data = 5'b00000;
          7'd024: rom_data = 5'b01100;
          7'd025: rom_data = 5'b00000;
          7'd026: rom_data = 5'b01100;
          7'd027: rom_data = 5'b00000;
          7'd028: rom_data = 5'b01100;
          7'd029: rom_data = 5'b00000;
          7'd030: rom_data = 5'b01100;
          7'd031: rom_data = 5'b00000;
          7'd032: rom_data = 5'b00100;
          7'd033: rom_data = 5'b00000; // Data clocked in
          7'd034: rom_data = 5'b00001; // Data latched
          7'd035: rom_data = 5'b00000;
          7'd036: rom_data = 5'b00000;
          7'd037: rom_data = 5'b00000;
          7'd038: rom_data = 5'b00000;
          7'd039: rom_data = 5'b00000;
          7'd040: rom_data = 5'b00000;
          7'd041: rom_data = 5'b00000;
          7'd042: rom_data = 5'b00000;
          7'd043: rom_data = 5'b00000;
          7'd044: rom_data = 5'b00000;
          7'd045: rom_data = 5'b00000;
          7'd046: rom_data = 5'b00000;
          7'd047: rom_data = 5'b00000;
          7'd048: rom_data = 5'b00000;
          7'd049: rom_data = 5'b00000;
          7'd050: rom_data = 5'b00000;
          7'd051: rom_data = 5'b00000;
          7'd052: rom_data = 5'b00000;
          7'd053: rom_data = 5'b00000;
          7'd054: rom_data = 5'b00000;
          7'd055: rom_data = 5'b00000;
          7'd056: rom_data = 5'b00000;
          7'd057: rom_data = 5'b00000;
          7'd058: rom_data = 5'b00000;
          7'd059: rom_data = 5'b00000;
          7'd060: rom_data = 5'b00000;
          7'd061: rom_data = 5'b00000;
          7'd062: rom_data = 5'b00000;
          7'd063: rom_data = 5'b00000;
          7'd064: rom_data = 5'b00010; // Begin mode switch
          7'd065: rom_data = 5'b00010;
          7'd066: rom_data = 5'b00010;
          7'd067: rom_data = 5'b00110;
          7'd068: rom_data = 5'b00000;
          7'd069: rom_data = 5'b00100;
          7'd070: rom_data = 5'b00010;
          7'd071: rom_data = 5'b00110;
          7'd072: rom_data = 5'b00011;
          7'd073: rom_data = 5'b00111;
          7'd074: rom_data = 5'b00010;
          7'd075: rom_data = 5'b00110;
          7'd076: rom_data = 5'b10010; // Special mode enabled
          7'd077: rom_data = 5'b00010;
          7'd078: rom_data = 5'b00010; // Add brightness and error detection here
          7'd079: rom_data = 5'b00010;
          7'd080: rom_data = 5'b00010;
          7'd081: rom_data = 5'b00010;
          7'd082: rom_data = 5'b00010;
          7'd083: rom_data = 5'b00010;
          7'd084: rom_data = 5'b00010;
          7'd085: rom_data = 5'b00010;
          7'd086: rom_data = 5'b00010;
          7'd087: rom_data = 5'b00010;
          7'd088: rom_data = 5'b00010;
          7'd089: rom_data = 5'b00010;
          7'd090: rom_data = 5'b00010;
          7'd091: rom_data = 5'b00010;
          7'd092: rom_data = 5'b00010;
          7'd093: rom_data = 5'b00010;
          7'd094: rom_data = 5'b00010;
          7'd095: rom_data = 5'b00010;
          7'd096: rom_data = 5'b00010;
          7'd097: rom_data = 5'b00010;
          7'd098: rom_data = 5'b00010;
          7'd099: rom_data = 5'b00010;
          7'd100: rom_data = 5'b00010;
          7'd101: rom_data = 5'b00010;
          7'd102: rom_data = 5'b00010;
          7'd103: rom_data = 5'b00010;
          7'd104: rom_data = 5'b00010;
          7'd105: rom_data = 5'b00010;
          7'd106: rom_data = 5'b00010;
          7'd107: rom_data = 5'b00010;
          7'd108: rom_data = 5'b00010;
          7'd109: rom_data = 5'b00010;
          7'd110: rom_data = 5'b00010;
          7'd111: rom_data = 5'b00010;
          7'd112: rom_data = 5'b00010;
          7'd113: rom_data = 5'b00010; // Begin mode switch
          7'd114: rom_data = 5'b00010;
          7'd115: rom_data = 5'b00010;
          7'd116: rom_data = 5'b00110;
          7'd117: rom_data = 5'b00000;
          7'd118: rom_data = 5'b00100;
          7'd119: rom_data = 5'b00010;
          7'd120: rom_data = 5'b00110;
          7'd121: rom_data = 5'b00010;
          7'd122: rom_data = 5'b00110;
          7'd123: rom_data = 5'b00010;
          7'd124: rom_data = 5'b00110;
          7'd125: rom_data = 5'b10010; // Normal mode enabled
          7'd126: rom_data = 5'b00010;
          7'd127: rom_data = 5'b00010;
        endcase // case (addr)
     end // always @ *
   
   
   assign load = data_reg[4];
   assign shift = data_reg[3];
   assign sclk = data_reg[2];
   assign output_enable_n = data_reg[1];
   assign latch_enable = data_reg[0];


endmodule
