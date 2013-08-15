
module panel_driver
  (
   input         clk,
   input         reset_n,
   input         shift,
   input         load_led_vals,
   input         load_brightness,
   input [7:0]   brightness,
   input [3:0]   read_port_row_addr,
   input [3:0]   write_port_row_addr,
   input         write_port_enable_red,
   input         write_port_enable_green, 
   input         write_port_enable_blue, 
   input [127:0] pwm_values,
   input [7:0]   pwm_step, 
   output        serial_data_out_red,
   output        serial_data_out_green,
   output        serial_data_out_blue
   );

   row_color_driver red_driver
     (.clk(clk), .reset_n(reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .brightness(brightness), .read_port_row_addr(read_port_row_addr),
      .write_port_row_addr(write_port_row_addr), 
      .write_port_enable(write_port_enable_red), .pwm_values(pwm_values),
      .pwm_step(pwm_step), .serial_data_out(serial_data_out_red));

   row_color_driver green_driver
     (.clk(clk), .reset_n(reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .brightness(brightness), .read_port_row_addr(read_port_row_addr),
      .write_port_row_addr(write_port_row_addr), 
      .write_port_enable(write_port_enable_green), .pwm_values(pwm_values),
      .pwm_step(pwm_step), .serial_data_out(serial_data_out_green));

   row_color_driver blue_driver
     (.clk(clk), .reset_n(reset_n), .shift(shift), 
      .load_led_vals(load_led_vals), .load_brightness(load_brightness),
      .brightness(brightness), .read_port_row_addr(read_port_row_addr),
      .write_port_row_addr(write_port_row_addr), 
      .write_port_enable(write_port_enable_blue), .pwm_values(pwm_values),
      .pwm_step(pwm_step), .serial_data_out(serial_data_out_blue));
   
   
endmodule // panel_driver
