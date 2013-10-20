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
   output [3:0]  row_addr,
   output [1:0]  panel_addr
   );

   wire          rxf_n, txe_n, panel_select_request, command_write_enable;
   wire [15:0]   panel_switches;
   wire [7:0]    data_bus;
   wire [15:0]   command_select;
   

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
      .panel_select_request(panel_select_request),
      .rd_n(rd_n),
      .wr_n(wr_n), 
      .command_write_enable(command_write_enable),
      .chunk_write_enable(chunk_write_enable));

   decoder #(.WIDTH(4)) command_decoder
     (.addr(data_bus[7:4]), .y(command_select));
   

   register_with_write_enable #(.WIDTH(4)) panel_sw_command_register
     (.clk(clk),
      .reset_n(reset_n),
      .write_enable(command_select[1] & command_write_enable),
      .d(command_select[1]),
      .q(panel_select_request));

   register_with_write_enable #(.WIDTH(2)) panel_addr_command_register
     (.clk(clk),
      .reset_n(reset_n),
      .write_enable(command_select[2] & command_write_enable),
      .d(data_bus[1:0]),
      .q(panel_addr));

   register_with_write_enable #(.WIDTH(4)) row_addr_command_register
     (.clk(clk),
      .reset_n(reset_n),
      .write_enable(command_select[3] & command_write_enable),
      .d(data_bus[3:0]),
      .q(row_addr));

   register_with_write_enable #(.WIDTH(4)) chunk_addr_command_register
     (.clk(clk),
      .reset_n(reset_n),
      .write_enable(command_select[4] & command_write_enable),
      .d(data_bus[3:0]),
      .q(chunk_addr));

   
   genvar        i;
   generate
      for (i=0; i<8; i=i+1)
        begin : nibble_registers
           register_with_write_enable #(.WIDTH(4)) nibble_register
             (.clk(clk), 
              .reset_n(reset_n), 
              .write_enable(command_select[i+5] & command_write_enable),
              .d(data_bus[3:0]),
              .q(chunk_data[4*i+3:4*i]));
        end
   endgenerate

endmodule // usb_controller

/* 
                    Command Table
 
 data_bus[7:4]  Description                       data_bus[3:0]
 -------------  --------------------------------  --------------------
 0 -            Unused / illegal                  N/A
 1 -            Request panel selector data       N/A
 2 -            Set panel address                 {2'b0, panel_addr}
 3 -            Set row address                   row_addr
 4 -            Set chunk address                 chunk_addr
 5 -            Set nibble 0 of chunk             nibble
 6 -            Set nibble 1 of chunk             nibble
 7 -            Set nibble 2 of chunk             nibble
 8 -            Set nibble 3 of chunk             nibble
 9 -            Set nibble 4 of chunk             nibble
 10 -           Set nibble 5 of chunk             nibble
 11 -           Set nibble 6 of chunk             nibble
 12 -           Set nibble 7 of chunk             nibble
 13 -           Unused / illegal                  N/A
 14 -           Unused / illegal                  N/A
 15 -           Unused / illegal                  N/A

  */
