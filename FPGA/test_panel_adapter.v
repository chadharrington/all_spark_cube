module test_panel_adapter
  (
   input         clk,
   input         test_panel_select_n,
   input [15:0]  led_vals_in,
   output [15:0] led_vals_out
   );

   synchronous_two_input_multiplexer #(.WIDTH(16)) mux
     (.clk(clk), 
      .select(test_panel_select_n),
      .in0({led_vals_in[7:0], led_vals_in[15:8]}),
      .in1(led_vals_in),
      .out(led_vals_out));

endmodule // test_panel_adapter
