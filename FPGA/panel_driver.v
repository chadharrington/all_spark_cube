
module panel_driver
  (
   input         clk,
   input         reset_n,
   input         test_panel_select_n, 
   input         shift,
   input         load_led_vals,
   input         load_brightness,
   input [3:0]   active_row,         
   input [7:0]   pwm_time,
   input [383:0] row_data_in,
   input [3:0]   row_data_row_addr,
   input         row_data_write_enable, 
   output [2:0]  serial_data_out
   );

   wire [383:0]  row_data_out;
   
   altera_dual_port_ram_simple #(.DATA_WIDTH(384), .ADDR_WIDTH(4)) ram
     (.clk(clk), 
      .write_enable(row_data_write_enable),
      .write_addr(row_data_row_addr),
      .read_addr(active_row),
      .data_in(row_data_in),
      .data_out(row_data_out));
   

   genvar       i;
   generate
      for (i=0; i<3; i=i+1)
        begin : color_component_drivers
           color_component_driver color_component_driver_instance
             (.clk(clk), 
              .reset_n(reset_n),
              .test_panel_select_n(test_panel_select_n),
              .shift(shift), 
              .load_led_vals(load_led_vals), 
              .load_brightness(load_brightness),
              .pwm_time(pwm_time), 
              .component_values({row_data_out[383-8*i:376-8*i],
                                 row_data_out[359-8*i:352-8*i],
                                 row_data_out[335-8*i:328-8*i],
                                 row_data_out[311-8*i:304-8*i],
                                 row_data_out[287-8*i:280-8*i],
                                 row_data_out[263-8*i:256-8*i],
                                 row_data_out[239-8*i:232-8*i],
                                 row_data_out[215-8*i:208-8*i],
                                 row_data_out[191-8*i:184-8*i],
                                 row_data_out[167-8*i:160-8*i],
                                 row_data_out[143-8*i:136-8*i],
                                 row_data_out[119-8*i:112-8*i],
                                 row_data_out[95-8*i:88-8*i],
                                 row_data_out[71-8*i:64-8*i],
                                 row_data_out[47-8*i:40-8*i],
                                 row_data_out[23-8*i:16-8*i]}),
              .serial_data_out(serial_data_out[i]));             
        end
   endgenerate
   
endmodule // panel_driver
