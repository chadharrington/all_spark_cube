module controller
  (
   input         clk,
   input         reset_n,
   input         test_panel_select_n,
   output        serial_clk,
   output        latch_enable,
   output        output_enable_n,
   output [11:0] serial_data_out,
   output [15:0] row_select_n
   );

   wire          global_reset_n, shift;
   wire          load, load_led_vals, load_brightness, special_mode;
   wire [18:0]   count;
   wire [6:0]    driver_step;
   wire [7:0]    pwm_time;
   wire [3:0]    row;

   wire [383:0]  row_colors;


   assign driver_step = {special_mode, count[5:0]};
   assign pwm_time = count[13:6];
   assign row = count[17:14];
   assign special_mode = count[18];
   assign load_led_vals = load & !special_mode;
   assign load_brightness = load & special_mode;

   // R, G, B order
   assign row_colors = { 
                         {8'h00, 8'h00, 8'hff}, // 16
                         {8'h22, 8'hff, 8'haa}, // 15
                         {8'h00, 8'h00, 8'h00}, // 14
                         {8'h00, 8'h00, 8'h00}, // 13
                         {8'hff, 8'h00, 8'h00}, // 12
                         {8'h00, 8'hff, 8'h00}, // 11
                         {8'h00, 8'h00, 8'hff}, // 10
                         {8'h00, 8'h00, 8'h00}, // 9
                         {8'hff, 8'h00, 8'h00}, // 8
                         {8'h00, 8'h00, 8'h00}, // 7
                         {8'h00, 8'h00, 8'h00}, // 6
                         {8'h00, 8'h00, 8'h00}, // 5
                         {8'h00, 8'h00, 8'hff}, // 4
                         {8'h00, 8'hff, 8'h00}, // 3
                         {8'hff, 8'h00, 8'h00}, // 2
                         {8'h00, 8'hff, 8'h00}}; // 1                         
   
   
   sync_async_reset resetter 
     (.clk(clk), .reset_n(reset_n), .synced_reset_n(global_reset_n));

   rom control_rom
     (.clk(clk), .reset_n(global_reset_n), .addr(driver_step),
      .load(load), .shift(shift), .sclk(serial_clk), 
      .output_enable_n(output_enable_n), .latch_enable(latch_enable));

   // Reset the counter after the special mode is run (2**18+2**6)
   binary_counter #(.N(19), .MAX_COUNT(2**18+2**6)) counter
     (.clk(clk), .reset_n(global_reset_n), .count(count));

   inverting_decoder #(.WIDTH(4)) row_driver_decoder
     (.addr(row), .y_n(row_select_n));


   genvar        i;
   generate
      for (i=0; i<4; i=i+1)
        begin : panel_drivers
           panel_driver panel_driver_instance
             (.clk(clk), 
              .reset_n(global_reset_n),
              .test_panel_select_n(test_panel_select_n),
              .shift(shift), 
              .load_led_vals(load_led_vals), 
              .load_brightness(load_brightness),
              .pwm_time(pwm_time),
              .row_colors(row_colors),
              .serial_data_out({serial_data_out[i*3+2], 
                                serial_data_out[i*3+1], 
                                serial_data_out[i*3]}));
        end
   endgenerate

endmodule // controller

