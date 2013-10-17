module controller
  (
   input         clk,
   input         reset_n,
   input         test_panel_select_n,
   input [383:0] row_data,
   input [3:0]   row_data_row_addr,
   input [1:0]   row_data_panel_addr,
   input         row_data_write_enable,
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
   wire [3:0]    active_row;
   wire [3:0]    panel_select;
   
   assign driver_step = {special_mode, count[5:0]};
   assign pwm_time = count[13:6];
   assign active_row = count[17:14];
   assign special_mode = count[18];
   assign load_led_vals = load & !special_mode;
   assign load_brightness = load & special_mode;

   sync_async_reset resetter 
     (.clk(clk), .reset_n(reset_n), .synced_reset_n(global_reset_n));

   rom control_rom
     (.clk(clk), .reset_n(global_reset_n), .addr(driver_step),
      .load(load), .shift(shift), .sclk(serial_clk), 
      .output_enable_n(output_enable_n), .latch_enable(latch_enable));

   // Reset the counter after the special mode is run (2**18+2**6)
   binary_counter #(.N(19), .MAX_COUNT(2**18+2**6)) counter
     (.clk(clk), .reset_n(global_reset_n), .count(count));

   decoder #(.WIDTH(2)) panel_addr_decoder
     (.addr(row_data_panel_addr), .y(panel_select));
   
   inverting_decoder #(.WIDTH(4)) row_driver_decoder
     (.addr(active_row), .y_n(row_select_n));


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
              .row_data_in(row_data),
              .row_data_row_addr(row_data_row_addr),
              .row_data_write_enable(panel_select[i] & row_data_write_enable),
              .serial_data_out({serial_data_out[i*3+2], 
                                serial_data_out[i*3+1], 
                                serial_data_out[i*3]}));
        end
   endgenerate

endmodule // controller

