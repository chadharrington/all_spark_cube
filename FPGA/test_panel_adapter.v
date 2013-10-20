module test_panel_adapter
  (
   input         clk,
   input         test_panel_select,
   input  [15:0] led_vals_in,
   output [15:0] led_vals_out
   );

   synchronous_two_input_multiplexer #(.WIDTH(16)) mux
     (.clk(clk), 
      .select(test_panel_select),
      .in0(led_vals_in),
      .in1({led_vals_in[7:0], led_vals_in[15:8]}),
      .out(led_vals_out));

endmodule // test_panel_adapter
