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
   wire         test_panel_select_n;
   wire [15:0]  panel_switches;
   wire [383:0] row_data;
   wire [3:0]   row_data_row_addr;
   wire [1:0]   row_data_panel_addr;
   wire         row_data_write_enable;
   
   // Resets are active low, ANDing them provides OR behavior
   assign reset_n_raw = KEY[0] & GPIO_2[11];
   assign clk = CLOCK_50;
   assign panel_switches = GPIO_1[31:16];
   assign LED = panel_switches[15:8];
   
   // TODO: Assign test_panel_select_n to GPIO_1[33]
   assign test_panel_select_n = 1'b0;
   //assign test_panel_select_n = GPIO_1[33];

   sync_async_reset resetter 
     (.clk(clk), .reset_n(reset_n_raw), .synced_reset_n(reset_n));

   usb_controller usb_cont
     (.clk(clk),
      .reset_n(reset_n),
      .panel_switches(panel_switches),
      .miso(GPIO_2[10]),
      .miosio(GPIO_2[7:0]),
      .sclk(GPIO_2[8]),
      .ss_n(GPIO_2[9]),
      .row_data_out(row_data),
      .row_data_row_addr(row_data_row_addr),
      .row_data_panel_addr(row_data_panel_addr),
      .row_data_write_enable(row_data_write_enable));
   
   controller cont
     (.clk(clk), 
      .reset_n(reset_n),
      .test_panel_select_n(test_panel_select_n),
      .row_data(row_data),
      .row_data_row_addr(row_data_row_addr),
      .row_data_panel_addr(row_data_panel_addr),
      .row_data_write_enable(row_data_write_enable),  
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

endmodule
