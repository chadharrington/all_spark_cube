module controller
  (
   input         clk,
   input         reset_n,
   input  [3:0]  switches,         
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

   wire          global_reset_n, shift;
   wire          load, load_led_vals, load_brightness, special_mode;
   wire [18:0]   count;
   wire [7:0]    write_addr;
   wire [127:0]  write_data;
   wire [15:0]   write_enables;
   wire [3:0]    write_port_row_addr;
   wire [7:0]    brightness; // TODO: Replace with host-controlled brightness

   sync_async_reset resetter 
     (.clk(clk), .reset_n(reset_n), .synced_reset_n(global_reset_n));

   rom control_rom
     (.clk(clk), .reset_n(global_reset_n), .addr({special_mode, count[5:0]}),
      .load(load), .shift(shift), .sclk(serial_clk), 
      .output_enable_n(output_enable_n), .latch_enable(latch_enable));

   // Counter bits:
   // 5:0   Serial output control sequence step
   // 13:6  PWM step
   // 17:14 Row number
   // 18    Special mode on/off
   // Reset the counter after the special mode is run (2**18+2**6)
   binary_counter #(.N(19), .MAX_COUNT(2**18+2**6)) counter
     (.clk(clk), .reset_n(global_reset_n), .count(count));

   inverting_decoder #(.WIDTH(4)) row_driver_decoder
     (.addr(count[17:14]), .y_n(row_select_n));

   // write_addr bits:
   // 7:4 row
   // 3:2 panel
   // 1:0 color (0:red, 1:green, 2:blue, 3:brightness)
   decoder #(.WIDTH(4)) write_addr_decoder
     (.addr(write_addr[3:0]), .y_n(write_enables));


   panel_driver panel_0
     (.clk(clk), .reset_n(global_reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .brightness(brightness), .read_port_row_addr(count[17:14]),
      .write_port_row_addr(write_port_row_addr), 
      .write_port_enable_red(write_enables[0]),
      .write_port_enable_green(write_enables[1]),
      .write_port_enable_blue(write_enables[2]),
      .pwm_values(write_data),
      .pwm_step(count[13:6]),
      .serial_data_out_red(serial_data_out_0_red),
      .serial_data_out_green(serial_data_out_0_green),
      .serial_data_out_blue(serial_data_out_0_blue));

      panel_driver panel_1
     (.clk(clk), .reset_n(global_reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .brightness(brightness), .read_port_row_addr(count[17:14]),
      .write_port_row_addr(write_port_row_addr), 
      .write_port_enable_red(write_enables[4]),
      .write_port_enable_green(write_enables[5]),
      .write_port_enable_blue(write_enables[6]),
      .pwm_values(write_data),
      .pwm_step(count[13:6]),
      .serial_data_out_red(serial_data_out_1_red),
      .serial_data_out_green(serial_data_out_1_green),
      .serial_data_out_blue(serial_data_out_1_blue));

   panel_driver panel_2
     (.clk(clk), .reset_n(global_reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .brightness(brightness), .read_port_row_addr(count[17:14]),
      .write_port_row_addr(write_port_row_addr), 
      .write_port_enable_red(write_enables[8]),
      .write_port_enable_green(write_enables[9]),
      .write_port_enable_blue(write_enables[10]),
      .pwm_values(write_data),
      .pwm_step(count[13:6]),
      .serial_data_out_red(serial_data_out_2_red),
      .serial_data_out_green(serial_data_out_2_green),
      .serial_data_out_blue(serial_data_out_2_blue));

      panel_driver panel_3
     (.clk(clk), .reset_n(global_reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .brightness(brightness), .read_port_row_addr(count[17:14]),
      .write_port_row_addr(write_port_row_addr), 
      .write_port_enable_red(write_enables[12]),
      .write_port_enable_green(write_enables[13]),
      .write_port_enable_blue(write_enables[14]),
      .pwm_values(write_data),
      .pwm_step(count[13:6]),
      .serial_data_out_red(serial_data_out_3_red),
      .serial_data_out_green(serial_data_out_3_green),
      .serial_data_out_blue(serial_data_out_3_blue));


   assign special_mode = count[18];
   assign load_led_vals = load & !special_mode;
   assign load_brightness = load & special_mode;
   assign write_port_row_addr = write_addr[7:4];

   // TODO: Replace with host-controlled brightness
   assign brightness = 8'hff;
   
   

endmodule // controller

