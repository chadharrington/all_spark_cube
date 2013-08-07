
module panel_driver
  (
   input  clk,
   input  reset_n,
   input  shift,
   input  load_led_vals,
   input  load_brightness,
   output serial_data_out_red,
   output serial_data_out_green,
   output serial_data_out_blue
   );

   wire [7:0] brightness;
   
   wire [15:0] brightness_extended;
   wire [15:0] vals_red, vals_green, vals_blue;
   

   piso_shift_register #(.WIDTH(16)) sr_red
     (.clk(clk), .reset_n(reset_n),
      .par_in_a(vals_red), .par_in_b(brightness_extended), 
      .load_a(load_led_vals), .load_b(load_brightness), 
      .shift(shift), .ser_out(serial_data_out_red));

   piso_shift_register #(.WIDTH(16)) sr_green
     (.clk(clk), .reset_n(reset_n),
      .par_in_a(vals_green), .par_in_b(brightness_extended), 
      .load_a(load_led_vals), .load_b(load_brightness), 
      .shift(shift), .ser_out(serial_data_out_green));

   piso_shift_register #(.WIDTH(16)) sr_blue
     (.clk(clk), .reset_n(reset_n),
      .par_in_a(vals_blue), .par_in_b(brightness_extended), 
      .load_a(load_led_vals), .load_b(load_brightness), 
      .shift(shift), .ser_out(serial_data_out_blue));

   assign brightness_extended = {8'h00, brightness};

   // Temporary - replace with RAM 
   assign vals_red = 16'haaaa;
   assign vals_green= 16'h5555;
   assign vals_blue = 16'haaaa;
   assign brightness = 8'hff;
   

   
   
endmodule // panel_driver
