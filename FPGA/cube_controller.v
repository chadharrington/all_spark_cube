module cube_controller
  (
   input        CLOCK_50, // Reference clock   
   input [1:0]  KEY,
   input [3:0]  SW,
   inout [12:0] GPIO_2,
   input [2:0]  GPIO_2_IN,
   inout [33:0] GPIO_0,
   input [1:0]  GPIO_0_IN,
   inout [33:0] GPIO_1,
   input [1:0]  GPIO_1_IN,
   output [7:0] LED
   );

   wire         clk, reset_n, reset_n_raw;
   wire         test_panel_select;
   wire [15:0]  panel_switches_raw;
   wire         rxf_n_raw, txe_n_raw, rd_n, wr_n, data_out_enable;
   wire [7:0]   data_bus_out;
   wire [31:0]  chunk_data;
   wire [3:0]   chunk_addr;
   wire         chunk_write_enable;
   wire [3:0]   row_addr;
   wire [1:0]   panel_addr;
   wire [4:0]   state_out;
   
   // Resets are active low, ANDing them provides OR behavior
   assign reset_n_raw = KEY[0] & GPIO_2[11];
   
   assign clk = CLOCK_50;
   assign panel_switches_raw = GPIO_1[31:16];
   assign rxf_n_raw = GPIO_2[8];
   assign txe_n_raw = GPIO_2[9];
   assign GPIO_2[7:0] = (data_out_enable) ? data_bus_out : 8'hzz;
   assign rd_n = GPIO_2[10];
   assign wr_n = GPIO_2[12];
   assign test_panel_select = SW[0];
   assign LED[0] = test_panel_select;
   assign LED[1] = !rxf_n_raw;
   assign LED[2] = !txe_n_raw;
   assign LED[7:3] = state_out;
   
   sync_async_reset resetter 
     (.clk(clk), .reset_n(reset_n_raw), .synced_reset_n(reset_n));

   usb_controller usb_cont
     (.clk(clk),
      .reset_n(reset_n),
      .panel_switches_raw(panel_switches_raw),
      .rxf_n_raw(rxf_n_raw),
      .txe_n_raw(txe_n_raw),
      .data_bus_in_raw(GPIO_2[7:0]),
      .data_bus_out(data_bus_out),
      .rd_n(rd_n),
      .wr_n(wr_n),
      .data_out_enable(data_out_enable),
      .chunk_data(chunk_data),
      .chunk_addr(chunk_addr),
      .chunk_write_enable(chunk_write_enable),
      .row_addr(row_addr),
      .panel_addr(panel_addr),
      .state_out(state_out)
      );
   
   led_controller led_cont
     (.clk(clk), 
      .reset_n(reset_n),
      .test_panel_select(test_panel_select),
      .chunk_data(chunk_data),
      .chunk_addr(chunk_addr),
      .chunk_write_enable(chunk_write_enable),
      .row_addr(row_addr),
      .panel_addr(panel_addr),
      .serial_clk(GPIO_0[0]), 
      .latch_enable(GPIO_0[1]), 
      .output_enable_n(GPIO_0[2]),
      // Note that the port numbers here are different from the schematic
      // in order to compensate for the PCB layout placement errors
      .serial_data_out({GPIO_0[27], GPIO_0[26], GPIO_0[11], // Panel 3
                        GPIO_0[25], GPIO_0[24], GPIO_0[10], // Panel 2
                        GPIO_0[16], GPIO_0[19], GPIO_0[9],  // Panel 1
                        GPIO_0[18], GPIO_0[17], GPIO_0[8]}),// Panel 0
      .row_select_n(GPIO_1[15:0])
      );

endmodule // cube_controller
