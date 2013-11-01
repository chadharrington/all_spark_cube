module usb_sequencer
  (
   input            clk,
   input            reset_n,
   input            rxf_n,
   input            txe_n,
   input            panel_select_request,
   input [15:0]     panel_switches,
   output reg [7:0] data_out,
   output           rd_n,
   output           wr_n, 
   output           data_out_enable,
   output           command_write_enable,
   output           clear_psr, 
   output [4:0]     state_out
   );

   reg [4:0]        state, next_state, output_bits;

   assign state_out = state;
   assign rd_n = output_bits[4];
   assign wr_n = output_bits[3];
   assign data_out_enable = output_bits[2];
   assign command_write_enable = output_bits[1];
   assign clear_psr = output_bits[0];
   
   // Labeled states
   localparam [4:0] 
     start_read = 5'd0,
     end_read = 5'd4,
     start_write = 5'd5,
     write_p1 = 5'd10,
     write_p2 = 5'd15,
     write_p3 = 5'd20,
     end_write = 5'd25;

   // State register
   always @(posedge clk, negedge reset_n)
     if (!reset_n)
       state <= start_read;
     else
       state <= next_state;

   // Next state logic
   always @(*)
     case (state)
       start_read:          
         if (panel_select_request)
           next_state = start_write;
         else
           if (rxf_n) 
             next_state = start_read;
           else 
             next_state = state + 1'b1;
       end_read:
         if (panel_select_request)
           next_state = start_write;
         else
           next_state = start_read;
       start_write:
         if (txe_n)
           next_state = start_write;
         else
           next_state = state + 1'b1;
       write_p1:
         if (txe_n)
           next_state = write_p1;
         else
           next_state = state + 1'b1;
       write_p2:
         if (txe_n)
           next_state = write_p2;
         else
           next_state = state + 1'b1;
       write_p3:
         if (txe_n)
           next_state = write_p3;
         else
           next_state = state + 1'b1;
       end_write:
         next_state = start_read;
       default:
         next_state = state + 1'b1;
     endcase // case (state)

   // Output logic
   always @(*)
     if (!reset_n)
       begin
          data_out = 8'hzz;
          output_bits = 4'b1100;
       end
     else
       case (state)
         0: // start_read
           begin
              data_out = 8'hzz;
              output_bits = 5'b11000;
           end
         1: // 
           begin
              data_out = 8'hzz;
              output_bits = 5'b01000;
           end
         2: // 
           begin
              data_out = 8'hzz;
              output_bits = 5'b01000;
           end
         3: // 
           begin
              data_out = 8'hzz;
              output_bits = 5'b01010;
           end
         4: // end_read
           begin
              data_out = 8'hzz;
              output_bits = 5'b11000;
           end
         5: // start_write
           begin
              data_out = 8'hzz;
              output_bits = 5'b11000;
           end
         6: // 
           begin
              data_out = {4'h1, panel_switches[3:0]};
              output_bits = 5'b11100;
           end
         7: // 
           begin
              data_out = {4'h1, panel_switches[3:0]};
              output_bits = 5'b10100;
           end
         8: // 
           begin
              data_out = {4'h1, panel_switches[3:0]};
              output_bits = 5'b10100;
           end
         9: // 
           begin
              data_out = {4'h1, panel_switches[3:0]};
              output_bits = 5'b11100;
           end
         10: // write_p1
           begin
              data_out = {4'h1, panel_switches[3:0]};
              output_bits = 5'b11100;
           end
         11: // 
           begin
              data_out = {4'h2, panel_switches[7:4]};
              output_bits = 5'b11100;
           end
         12: // 
           begin
              data_out = {4'h2, panel_switches[7:4]};
              output_bits = 5'b10100;
           end
         13: // 
           begin
              data_out = {4'h2, panel_switches[7:4]};
              output_bits = 5'b10100;
           end
         14: // 
           begin
              data_out = {4'h2, panel_switches[7:4]};
              output_bits = 5'b11100;
           end
         15: // write_p2
           begin
              data_out = {4'h2, panel_switches[7:4]};
              output_bits = 5'b11100;
           end
         16: // 
           begin
              data_out = {4'h3, panel_switches[11:8]};
              output_bits = 5'b11100;
           end
         17: // 
           begin
              data_out = {4'h3, panel_switches[11:8]};
              output_bits = 5'b10100;
           end
         18: // 
           begin
              data_out = {4'h3, panel_switches[11:8]};
              output_bits = 5'b10100;
           end
         19: // 
           begin
              data_out = {4'h3, panel_switches[11:8]};
              output_bits = 5'b11100;
           end
         20: // write_p3
           begin
              data_out = {4'h3, panel_switches[11:8]};
              output_bits = 5'b11100;
           end
         21: // 
           begin
              data_out = {4'h4, panel_switches[15:12]};
              output_bits = 5'b11100;
           end
         22: // 
           begin
              data_out = {4'h4, panel_switches[15:12]};
              output_bits = 5'b10100;
           end
         23: // 
           begin
              data_out = {4'h4, panel_switches[15:12]};
              output_bits = 5'b10100;
           end
         24: // 
           begin
              data_out = {4'h4, panel_switches[15:12]};
              output_bits = 5'b11101;
           end
         25: // end_write
           begin
              data_out = {4'h4, panel_switches[15:12]};
              output_bits = 5'b11100;
           end
         default: // default
           begin
              data_out = 8'hzz;
              output_bits = 5'b11000;
           end
       endcase // case (state)

endmodule // usb_sequencer
