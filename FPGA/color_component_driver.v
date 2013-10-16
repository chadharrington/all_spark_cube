
module color_component_driver
  (
   input         clk,
   input         reset_n,
   input         test_panel_select_n, 
   input         shift,
   input         load_led_vals,
   input         load_brightness,
   input [7:0]   pwm_time,
   input [127:0] component_values,
   output        serial_data_out
   );

   wire [7:0]    brightness;
   wire [15:0]   brightness_extended;
   wire [15:0]   pwm_out;
   wire [15:0]   led_vals_out;
   

   assign brightness = 8'hff; //TODO: Replace with host-defined brightness
   assign brightness_extended = {8'h00, brightness};

   test_panel_adapter tpa
     (.clk(clk),
      .test_panel_select_n(test_panel_select_n),
      .led_vals_in(pwm_out),
      .led_vals_out(led_vals_out));
   
   piso_shift_register #(.WIDTH(16)) sr
     (.clk(clk), .reset_n(reset_n),
      .par_in_a(led_vals_out), .par_in_b(brightness_extended), 
      .load_a(load_led_vals), .load_b(load_brightness), 
      .shift(shift), .ser_out(serial_data_out));


   genvar        i;
   generate
      for (i=0; i<16; i=i+1)
        begin : comparator
           assign pwm_out[i] = pwm_time < component_values[8*i+7:8*i];
        end
   endgenerate
   
endmodule // color_component_driver
