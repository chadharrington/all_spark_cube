
module panel_driver
  (
   input        clk,
   input        reset_n,
   input        shift,
   input        load_led_vals,
   input        load_brightness,
   input [7:0]  pwm_time,
   output [2:0] serial_data_out
   );

   wire [7:0]   component_values[2:0];

   // Purple-ish color
   assign component_values[0] = 8'd153; // red
   assign component_values[1] = 8'd0;  // green
   assign component_values[2] = 8'd153;  // blue
   

   genvar       i;
   generate
      for (i=0; i<3; i=i+1)
        begin : color_component_drivers
           color_component_driver color_component_driver_instance
             (.clk(clk), .reset_n(reset_n), .shift(shift), 
              .load_led_vals(load_led_vals), .load_brightness(load_brightness),
              .pwm_time(pwm_time), .component_value(component_values[i]),
              .serial_data_out(serial_data_out[i]));
        end
   endgenerate

   
endmodule // panel_driver
