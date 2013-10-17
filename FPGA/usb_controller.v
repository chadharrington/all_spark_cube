module usb_controller
  (
   input          clk,
   input          reset_n,
   input  [15:0]  panel_switches,
   input          miso,
   inout  [7:0]   miosio,
   output         sclk,
   output         ss_n,
   output [383:0] row_data_out,
   output [3:0]   row_data_row_addr,
   output [1:0]   row_data_panel_addr,
   output         row_data_write_enable
   );

endmodule // usb_controller


