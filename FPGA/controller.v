module controller
  (
   input         clk,
   input         reset_n,
   output        serial_clk,
   output        latch_enable,
   output        output_enable_n,
   output        serial_data_out_0_red,
   output        serial_data_out_1_red,
   output        serial_data_out_2_red,
   output        serial_data_out_3_red,
   output        serial_data_out_0_green,
   output        serial_data_out_1_green,
   output        serial_data_out_2_green,
   output        serial_data_out_3_green,
   output        serial_data_out_0_blue,
   output        serial_data_out_1_blue,
   output        serial_data_out_2_blue,
   output        serial_data_out_3_blue,
   output [15:0] row_select_n
   );

   wire          global_reset_n, load, load_led_vals, load_brightness, shift;
   wire [18:0]   count;

   sync_async_reset resetter 
     (.clk(clk), .reset_n(reset_n), .synced_reset_n(global_reset_n));

   rom control_rom
     (.clk(clk), .reset_n(global_reset_n), .addr({count[17], count[5:0]}),
      .load(load), .shift(shift), .sclk(serial_clk), 
      .output_enable_n(output_enable_n), .latch_enable(latch_enable));

   // Counter bits:
   // 0-5   Serial output control sequence step
   // 6-13  PWM step
   // 14-17 Row number
   // 18    Special mode on/off
   // Reset the counter after the special mode is run (2**18+2**6)
   binary_counter #(.N(19), .MAX_COUNT(2**18+2**6)) counter
     (.clk(clk), .reset_n(global_reset_n), .count(count));

   inverting_decoder decoder
     (.addr(count[13:6]), .y_n(row_select_n));

   panel_driver panel_0
     (.clk(clk), .reset_n(global_reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .serial_data_out_red(serial_data_out_0_red),
      .serial_data_out_green(serial_data_out_0_green),
      .serial_data_out_blue(serial_data_out_0_blue));
   
   panel_driver panel_1
     (.clk(clk), .reset_n(global_reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .serial_data_out_red(serial_data_out_1_red),
      .serial_data_out_green(serial_data_out_1_green),
      .serial_data_out_blue(serial_data_out_1_blue));

   panel_driver panel_2
     (.clk(clk), .reset_n(global_reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .serial_data_out_red(serial_data_out_2_red),
      .serial_data_out_green(serial_data_out_2_green),
      .serial_data_out_blue(serial_data_out_2_blue));
   
   panel_driver panel_3
     (.clk(clk), .reset_n(global_reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .serial_data_out_red(serial_data_out_3_red),
      .serial_data_out_green(serial_data_out_3_green),
      .serial_data_out_blue(serial_data_out_3_blue));

   assign load_led_vals = load & !count[17];
   assign load_brightness = load & count[17];
   

endmodule // controller

