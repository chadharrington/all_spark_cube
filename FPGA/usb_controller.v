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
   output [3:0]  chunk_addr,
   output        chunk_write_enable,
   output [3:0]  row_data_row_addr,
   output [1:0]  row_data_panel_addr
   );

   wire [15:0]   panel_switches;
   wire [7:0]    data_bus;
   wire          rxf_n, txe_n, nibble_write_enable;
   wire [15:0]   nibble_select;
   

   synchronizer #(.WIDTH(16)) panel_sw_sync
     (.clk(clk), .reset_n(reset_n), .in(panel_switches_raw), .out(panel_switches));
   
   synchronizer #(.WIDTH(8)) data_bus_input_sync
     (.clk(clk), .reset_n(reset_n), .in(data_bus_raw), .out(data_bus));

   synchronizer #(.WIDTH(2)) rx_tx_sync
     (.clk(clk), .reset_n(reset_n), .in({rxf_n_raw, txe_n_raw}), .out({rxf_n, txe_n}));

   usb_sequencer seq
     (.clk(clk), 
      .reset_n(reset_n), 
      .rxf_n(rxf_n), 
      .txe_n(txe_n), 
      .rd_n(rd_n),
      .wr_n(wr_n), 
      .nibble_write_enable(nibble_write_enable),
      .chunk_write_enable(chunk_write_enable));

   decoder #(.WIDTH(4)) nibble_decoder
     (.addr(data_bus[7:4]), .y(nibble_select));
   
   
   genvar        i;
   generate
      for (i=0; i<8; i=i+1)
        begin : nibble_registers
           register_with_write_enable #(.WIDTH(1)) nibble_register
             (.clk(clk), 
              .reset_n(reset_n), 
              .write_enable(nibble_select[i] & nibble_write_enable),
              .d(data_bus[3:0]),
              .q(chunk_data[4*i+3:4*i]));
        end
   endgenerate

endmodule // usb_controller


