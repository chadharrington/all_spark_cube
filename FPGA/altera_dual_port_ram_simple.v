
module altera_dual_port_ram_simple
  #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 10)
   (
    input                   clk,
    input                   write_enable,
    input  [ADDR_WIDTH-1:0] write_addr,
    input  [ADDR_WIDTH-1:0] read_addr,
    input  [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
    );

   reg [DATA_WIDTH-1:0]     ram [2**ADDR_WIDTH-1:0];
   reg [ADDR_WIDTH-1:0]     addr_reg;

   always @(posedge clk)
     begin
        if (write_enable)
          ram[write_addr] <= data_in;
        addr_reg <= read_addr;
     end

   assign data_out = ram[addr_reg];

endmodule // altera_dual_port_ram_simple

        
