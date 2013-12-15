module panel_driver
  (
   input        clk,
   input        reset_n,
   input        test_panel_select_n, 
   input        shift,
   input        load_led_vals,
   input        load_brightness,
   input [7:0]  pwm_time,
   input [31:0] chunk_data,
   input [3:0]  chunk_addr,
   input        chunk_write_enable,
   input [3:0]  row_addr,
   input [3:0]  active_row_addr,
   output [2:0] serial_data_out
   );

   wire [15:0]  chunk_select;
   wire [383:0] row_data;

   
   decoder #(.WIDTH(4)) chunk_addr_decoder
     (.addr(chunk_addr), .y(chunk_select));

   genvar        i;
   generate
      for (i=0; i<12; i=i+1)
        begin : rams
           altera_dual_port_ram_simple #(.DATA_WIDTH(32), .ADDR_WIDTH(8)) ram
             (.clk(clk),
              .write_enable(chunk_select[i] & chunk_write_enable),
              .write_addr({4'h0, row_addr}),
              .read_addr({4'h0, active_row_addr}),
              .data_in(chunk_data),
              .data_out(row_data[32*i+31:32*i]));
        end
   endgenerate
   
   genvar        j;
   generate
      for (j=0; j<3; j=j+1)
        begin : color_component_drivers
           color_component_driver color_component_driver_instance
             (.clk(clk), 
              .reset_n(reset_n),
              .test_panel_select_n(test_panel_select_n),
              .shift(shift), 
              .load_led_vals(load_led_vals), 
              .load_brightness(load_brightness),
              .pwm_time(pwm_time), 
              .component_values({row_data[383-8*j:376-8*j],
                                 row_data[359-8*j:352-8*j],
                                 row_data[335-8*j:328-8*j],
                                 row_data[311-8*j:304-8*j],
                                 row_data[287-8*j:280-8*j],
                                 row_data[263-8*j:256-8*j],
                                 row_data[239-8*j:232-8*j],
                                 row_data[215-8*j:208-8*j],
                                 row_data[191-8*j:184-8*j],
                                 row_data[167-8*j:160-8*j],
                                 row_data[143-8*j:136-8*j],
                                 row_data[119-8*j:112-8*j],
                                 row_data[95-8*j:88-8*j],
                                 row_data[71-8*j:64-8*j],
                                 row_data[47-8*j:40-8*j],
                                 row_data[23-8*j:16-8*j]}),
              .serial_data_out(serial_data_out[j]));             
        end
   endgenerate
   
endmodule // panel_driver
