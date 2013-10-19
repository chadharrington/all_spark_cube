module usb_controller
  (
   input         clk,
   input         reset_n,
   input [15:0]  panel_switches_raw,
   input         rxf_n_raw,
   input         txe_n_raw,
   inout [7:0]   data_bus_raw,
   output        rd_n,
   output        wr_n,
   output [31:0] chunk_data,
   output [3:0]  chunk_data_addr,
   output        chunk_data_write_enable,
   output [3:0]  row_data_row_addr,
   output [1:0]  row_data_panel_addr
   );

   wire [15:0]    panel_switches;
   wire [7:0]     data_bus;
   wire           rxf_n, txe_n;
      

  synchronizer #(.WIDTH(16)) panel_sw_sync
    (.clk(clk), .reset_n(reset_n), .in(panel_switches_raw), .out(panel_switches));
   
  synchronizer #(.WIDTH(8)) data_bus_input_sync
    (.clk(clk), .reset_n(reset_n), .in(data_bus_raw), .out(data_bus));

  synchronizer #(.WIDTH(2)) rx_tx_sync
    (.clk(clk), .reset_n(reset_n), .in({rxf_n_raw, txe_n_raw}), .out({rxf_n, txe_n}));

   

   

endmodule // usb_controller


