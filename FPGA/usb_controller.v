module usb_controller
  (
   input         clk,
   input         reset_n,
   input [15:0]  panel_switches_raw,
   input         rxf_n_raw,
   input         txe_n_raw,
   input [7:0]   data_bus_in_raw,
   output [7:0]  data_bus_out,
   output        rd_n,
   output        wr_n,
   output        data_out_enable,
   output [31:0] chunk_data,
   output [3:0]  chunk_addr,
   output        chunk_write_enable,
   output [3:0]  row_addr,
   output [1:0]  panel_addr,
   output [4:0]  state_out
   );

   wire          rxf_n, txe_n, panel_select_request;
   wire          command_write_enable;
   wire [15:0]   panel_switches;
   wire [7:0]    data_bus_in;
   wire [15:0]   command_select;

   assign chunk_write_enable = command_select[13] & command_write_enable;

   synchronizer #(.WIDTH(16)) panel_sw_sync
     (.clk(clk), .reset_n(reset_n), .in(panel_switches_raw), .out(panel_switches));

   synchronizer #(.WIDTH(8)) data_bus_input_sync
     (.clk(clk), .reset_n(reset_n), .in(data_bus_in_raw), .out(data_bus_in));

   synchronizer #(.WIDTH(2)) rx_tx_sync
     (.clk(clk), .reset_n(reset_n), .in({rxf_n_raw, txe_n_raw}), .out({rxf_n, txe_n}));

   usb_sequencer seq
     (.clk(clk), 
      .reset_n(reset_n), 
      .rxf_n(rxf_n), 
      .txe_n(txe_n),
      .panel_select_request(panel_select_request),
      .panel_switches(panel_switches),
      .data_out(data_bus_out),
      .rd_n(rd_n),
      .wr_n(wr_n),
      .data_out_enable(data_out_enable),
      .command_write_enable(command_write_enable),
      .state_out(state_out));
   
   decoder #(.WIDTH(4)) command_decoder
     (.addr(data_bus_in[7:4]), .y(command_select));

   register_with_write_enable #(.WIDTH(1)) panel_sw_command_register
     (.clk(clk),
      .reset_n(reset_n),
      .write_enable(command_write_enable),
      .d(command_select[1]),
      .q(panel_select_request));

   register_with_write_enable #(.WIDTH(2)) panel_addr_command_register
     (.clk(clk),
      .reset_n(reset_n),
      .write_enable(command_select[2] & command_write_enable),
      .d(data_bus_in[1:0]),
      .q(panel_addr));

   register_with_write_enable #(.WIDTH(4)) row_addr_command_register
     (.clk(clk),
      .reset_n(reset_n),
      .write_enable(command_select[3] & command_write_enable),
      .d(data_bus_in[3:0]),
      .q(row_addr));

   register_with_write_enable #(.WIDTH(4)) chunk_addr_command_register
     (.clk(clk),
      .reset_n(reset_n),
      .write_enable(command_select[4] & command_write_enable),
      .d(data_bus_in[3:0]),
      .q(chunk_addr));

   
   genvar        i;
   generate
      for (i=0; i<8; i=i+1)
        begin : nibble_registers
           register_with_write_enable #(.WIDTH(4)) nibble_register
             (.clk(clk), 
              .reset_n(reset_n), 
              .write_enable(command_select[i+5] & command_write_enable),
              .d(data_bus_in[3:0]),
              .q(chunk_data[4*i+3:4*i]));
        end
   endgenerate

endmodule // usb_controller

/* 
                    PC to FPGA Command Table
 
 Command           Description                       Parameter
 data_bus_in[7:4]                                    data_bus[3:0]
 ----------------  --------------------------------  --------------------
 0 -               Unused / illegal                  N/A
 1 -               Request panel selector data       N/A
 2 -               Set panel address                 {2'b0, panel_addr}
 3 -               Set row address                   row_addr
 4 -               Set chunk address                 chunk_addr
 5 -               Set nibble 0 of chunk             nibble
 6 -               Set nibble 1 of chunk             nibble
 7 -               Set nibble 2 of chunk             nibble
 8 -               Set nibble 3 of chunk             nibble
 9 -               Set nibble 4 of chunk             nibble
 10 -              Set nibble 5 of chunk             nibble
 11 -              Set nibble 6 of chunk             nibble
 12 -              Set nibble 7 of chunk             nibble
 13 -              Write chunk                       N/A
 14 -              Unused / illegal                  N/A
 15 -              Unused / illegal                  N/A

 
 
                    FPGA to PC Command Table
 
 Command            Description                       Parameter 
 data_bus_out[7:4]                                    data_bus[3:0]
 -----------------  --------------------------------  --------------------
 0 -                Unused / illegal                  N/A
 1 -                Set panel 0 number                panel_switches[3:0]
 2 -                Set panel 1 number                panel_switches[7:4]
 3 -                Set panel 2 number                panel_switches[11:8]
 4 -                Set panel 3 number                panel_switches[15:12]   
 5 -                Unused / illegal                  N/A
 6 -                Unused / illegal                  N/A
 7 -                Unused / illegal                  N/A
 8 -                Unused / illegal                  N/A
 9 -                Unused / illegal                  N/A
 10 -               Unused / illegal                  N/A
 10 -               Unused / illegal                  N/A
 11 -               Unused / illegal                  N/A
 12 -               Unused / illegal                  N/A
 13 -               Unused / illegal                  N/A
 14 -               Unused / illegal                  N/A
 15 -               Unused / illegal                  N/A

  */
