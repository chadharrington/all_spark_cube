module controller
  (
   input       clk,
   input       reset_n,
   input [7:0] led_vals,
   input [7:0] brightness,
   output      serial_clk,
   output      serial_out,
   output      output_enable_n,
   output      latch_enable
   );

   wire        global_reset_n, load, load_led_vals, load_brightness, shift;
   wire [17:0] count;

   sync_async_reset resetter 
     (.clk(clk), .reset_n(reset_n), .synced_reset_n(global_reset_n));

   piso_shift_register sr
     (.clk(clk), .reset_n(global_reset_n), 
      .par_in_a(led_vals), .par_in_b(brightness), 
      .load_a(load_led_vals), .load_b(load_brightness), 
      .shift(shift), .ser_out(serial_out));

   rom control_rom
     (.clk(clk), .reset_n(global_reset_n), .addr({count[17], count[4:0]}),
      .load(load), .shift(shift), .sclk(serial_clk), 
      .output_enable_n(output_enable_n), .latch_enable(latch_enable));

   // Reset the counter after the special mode is run (2**17+31)
   binary_counter #(.N(18), .MAX_COUNT(2**17+31)) counter
     (.clk(clk), .reset_n(global_reset_n), .count(count));

   assign load_led_vals = load & !count[17];
   assign load_brightness = load & count[17];

endmodule // controller




