
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
   wire [15:0]   out;
   wire [15:0]   led_vals_out;
   

   assign brightness = 8'hff; //TODO: Replace with host-defined brightness
   assign brightness_extended = {8'h00, brightness};

   // Odd & even columns are switched on the cube panels
   piso_shift_register #(.WIDTH(16)) sr
     (.clk(clk), .reset_n(reset_n),
      .par_in_a({out[1], out[0], out[3], out[2],
                 out[5], out[4], out[7], out[6], 
                 out[9], out[8], out[11], out[10],
                 out[13], out[12], out[15], out[14]}),
      .par_in_b(brightness_extended), 
      .load_a(load_led_vals), .load_b(load_brightness), 
      .shift(shift), .ser_out(serial_data_out));


   genvar        i;
   generate
      for (i=0; i<16; i=i+1)
        begin : comparator
           assign out[i] = pwm_time < component_values[8*i+7:8*i];
        end
   endgenerate
   
endmodule // color_component_driver
