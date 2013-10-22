module usb_sequencer
  (
   input        clk,
   input        reset_n,
   input        rxf_n,
   input        txe_n,
   input        panel_select_request,
   input [15:0] panel_switches,
   inout [7:0]  data_bus_raw,
   output       rd_n,
   output       wr_n, 
   output       command_write_enable,
   output [4:0] state_out
   );

   reg [4:0]    state, next_state;

   assign state_out = state;
   
   // Labeled states
   localparam [4:0] 
     start_read = 5'd0,
     end_read = 5'd3,
     start_write = 5'd4,
     write_p1 = 5'd9,
     write_p2 = 5'd14,
     write_p3 = 5'd19,
     end_write = 5'd24;

   // State register
   always @(posedge clk, negedge reset_n)
     if (!reset)
       state <= start_read;
     else
       state <= next_state;

   // Next state logic
   always @(*)
     case (state)
       start_read:          
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
     case (state)
       0: // start_read
         begin
            data_bus_raw = 8'hzz;
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       1: // 
         begin
            data_bus_raw = 8'hzz;
            rd_n = 0;
            wr_n = 1;
            cmd_we = 0;
         end
       2: // 
         begin
            data_bus_raw = 8'hzz;
            rd_n = 0;
            wr_n = 1;
            cmd_we = 1;
         end
       3: // end_read
         begin
            data_bus_raw = 8'hzz;
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       4: // start_write
         begin
            data_bus_raw = 8'hzz;
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       5: // 
         begin
            data_bus_raw = {4'h1, panel_switches[3:0]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       6: // 
         begin
            data_bus_raw = {4'h1, panel_switches[3:0]};
            rd_n = 1;
            wr_n = 0;
            cmd_we = 0;
         end
       7: // 
         begin
            data_bus_raw = {4'h1, panel_switches[3:0]};
            rd_n = 1;
            wr_n = 0;
            cmd_we = 0;
         end
       8: // 
         begin
            data_bus_raw = {4'h1, panel_switches[3:0]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       9: // write_p1
         begin
            data_bus_raw = {4'h1, panel_switches[3:0]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       10: // 
         begin
            data_bus_raw = {4'h2, panel_switches[7:4]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       11: // 
         begin
            data_bus_raw = {4'h2, panel_switches[7:4]};
            rd_n = 1;
            wr_n = 0;
            cmd_we = 0;
         end
       12: // 
         begin
            data_bus_raw = {4'h2, panel_switches[7:4]};
            rd_n = 1;
            wr_n = 0;
            cmd_we = 0;
         end
       13: // 
         begin
            data_bus_raw = {4'h2, panel_switches[7:4]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       14: // write_p2
         begin
            data_bus_raw = {4'h2, panel_switches[7:4]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       15: // 
         begin
            data_bus_raw = {4'h3, panel_switches[11:8]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       16: // 
         begin
            data_bus_raw = {4'h3, panel_switches[11:8]};
            rd_n = 1;
            wr_n = 0;
            cmd_we = 0;
         end
       17: // 
         begin
            data_bus_raw = {4'h3, panel_switches[11:8]};
            rd_n = 1;
            wr_n = 0;
            cmd_we = 0;
         end
       18: // 
         begin
            data_bus_raw = {4'h3, panel_switches[11:8]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       19: // write_p3
         begin
            data_bus_raw = {4'h3, panel_switches[11:8]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       20: // 
         begin
            data_bus_raw = {4'h4, panel_switches[15:12]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       21: // 
         begin
            data_bus_raw = {4'h4, panel_switches[15:12]};
            rd_n = 1;
            wr_n = 0;
            cmd_we = 0;
         end
       22: // 
         begin
            data_bus_raw = {4'h4, panel_switches[15:12]};
            rd_n = 1;
            wr_n = 0;
            cmd_we = 0;
         end
       23: // 
         begin
            data_bus_raw = {4'h4, panel_switches[15:12]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
       24: // end_write
         begin
            data_bus_raw = {4'h4, panel_switches[15:12]};
            rd_n = 1;
            wr_n = 1;
            cmd_we = 0;
         end
     endcase // case (state)

endmodule // usb_sequencer
