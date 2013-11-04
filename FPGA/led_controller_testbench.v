`timescale 1ns / 10ps

module led_controller_testbench;

   reg         clk;
   reg         reset_n;
   reg         test_panel_select_n;
   reg [31:0]  chunk_data;
   reg [3:0]   chunk_addr;
   reg         chunk_write_enable;
   reg [3:0]   row_addr;
   reg [1:0]   panel_addr;
   wire        serial_clk;
   wire        latch_enable;
   wire        output_enable_n;
   wire [11:0] serial_data_out;
   wire [15:0] row_select_n;

   led_controller uut
     (.clk(clk), .reset_n(reset_n), .test_panel_select_n(test_panel_select_n),
      .chunk_data(chunk_data), .chunk_addr(chunk_addr),
      .chunk_write_enable(chunk_write_enable), .row_addr(row_addr),
      .panel_addr(panel_addr), .serial_clk(serial_clk), 
      .latch_enable(latch_enable), .output_enable_n(output_enable_n),
      .serial_data_out(serial_data_out), .row_select_n(row_select_n)
      );

   always begin  // 50MHz clock
      clk = 1'b1;
      #10;
      clk = 1'b0;
      #10;
   end

   initial begin
      reset_n = 1'b0;
      test_panel_select_n = 1'b0;
      chunk_data = 32'hffffffff;
      chunk_addr = 4'h0;
      chunk_write_enable = 1'b0;
      row_addr = 4'h0;
      panel_addr = 2'h3;
      #100;
      
      reset_n = 1'b1;
      #200;

      chunk_write_enable = 1'b1;
      #40;

      chunk_write_enable = 1'b0;
      #660;
      
      $stop;
   end // initial begin

endmodule // led_controller_testbench

