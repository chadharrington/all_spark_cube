`timescale 1ns / 10ps

module usb_controller_testbench;

   reg         clk;
   reg         reset_n;
   reg [15:0]  panel_switches_raw;
   reg         rxf_n_raw;
   reg         txe_n_raw;
   reg [7:0]   data_bus_in_raw;
   wire [7:0]  data_bus_out;
   wire        rd_n;
   wire        wr_n;
   wire        data_out_enable;
   wire [31:0] chunk_data;
   wire [3:0]  chunk_addr;
   wire        chunk_write_enable;
   wire [3:0]  row_addr;
   wire [1:0]  panel_addr;
   wire [4:0]  state_out;

   usb_controller uut
     (.clk(clk), .reset_n(reset_n), .panel_switches_raw(panel_switches_raw),
      .rxf_n_raw(rxf_n_raw), .txe_n_raw(txe_n_raw), 
      .data_bus_in_raw(data_bus_in_raw), .data_bus_out(data_bus_out), 
      .rd_n(rd_n), .wr_n(wr_n), .data_out_enable(data_out_enable),
      .chunk_data(chunk_data), .chunk_addr(chunk_addr), 
      .chunk_write_enable(chunk_write_enable), .row_addr(row_addr),
      .panel_addr(panel_addr), .state_out(state_out));

   always begin  // 50MHz clock
      clk = 1'b1;
      #10;
      clk = 1'b0;
      #10;
   end

   initial begin
      // Initial conditions
      reset_n = 0;    // start out in reset mode
      panel_switches_raw = 16'hfdec;
      rxf_n_raw = 1;  // no data to read for now
      txe_n_raw = 0;  // there is room in the tx buffer
      data_bus_in_raw = 8'h00; // no data on bus
      #100;

      reset_n = 1; // enter run mode
      data_bus_in_raw = 8'h10;
      #100;

      rxf_n_raw = 0; // indicate data to be read
      #1000
      
      $stop;
   end


endmodule // usb_controller_testbench

