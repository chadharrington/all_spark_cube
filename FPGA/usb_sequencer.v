module usb_sequencer
  (
   input  clk,
   input  reset_n,
   input  rxf_n,
   input  txe_n,
   input  panel_select_request,
   output rd_n,
   output wr_n, 
   output command_write_enable,
   output chunk_write_enable
   );

   assign rd_n = 1'b1;
   assign wr_n = 1'b0;
   assign command_write_enable = 1'b1;
   assign chunk_write_enable = 1'b1;
   
   

endmodule // usb_sequencer
