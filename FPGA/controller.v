module controller
  (
   input         clk,
   input         reset_n,
   output        serial_clk,
   output        latch_enable,
   output        output_enable_n,
   output [3:0]  serial_data_out_red,
   output [3:0]  serial_data_out_green,
   output [3:0]  serial_data_out_blue,
   output [15:0] row_select_n
   );

   wire          global_reset_n, load, load_led_vals, load_brightness, shift;
   wire [18:0]   count;

   //TODO: Remove these debugging lines
   wire [3:0]    row;
   assign row = count[17:14];
   
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
     (.addr(row), .y_n(row_select_n));

   genvar        i;
   generate
      for (i=0; i<4; i=i+1)
        begin : panel_drivers
           panel_driver panel_driver_instance
             (.clk(clk), .reset_n(global_reset_n), .shift(shift), 
              .load_led_vals(load_led_vals), .load_brightness(load_brightness),
              .serial_data_out_red(serial_data_out_red[i]),
              .serial_data_out_green(serial_data_out_green[i]),
              .serial_data_out_blue(serial_data_out_blue[i]));
        end
   endgenerate
   
   assign load_led_vals = load & !count[17];
   assign load_brightness = load & count[17];
   

endmodule // controller

