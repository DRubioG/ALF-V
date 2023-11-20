// ========================================================
// IEEE STD 1364-2001 Verilog file: rom4096x32.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
// ========================================================
// Initialize the ROM with $readmemh. For Vivado
// use the MIF files extension. Without this file,
// this design will not compile. See Verilog
// LRM 1364-2001 Section 17.2.8 for details on the
// format of this file.
// ========================================================
module rom4096x32
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=12)
(input clk,
// System clock
input reset,
// Asynchronous reset
input [0:(ADDR_WIDTH-1)] address, // Address input
output reg [0:(DATA_WIDTH-1)] q); // Data output
// ========================================================
// Declare the ROM variable
reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];
initial
begin
$readmemh("flash_mb.mif", rom);
end
always @ (posedge clk or negedge reset)
if (~reset)
q <= 0;
else
q <= rom[address];
endmodule
