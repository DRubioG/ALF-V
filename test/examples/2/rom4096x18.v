//==========================================================
// IEEE STD 1364-2001 Verilog file: prog_rom.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//==========================================================
// Initialize the ROM with $readmemh. Put the memory
// contents in the file trisc0fac.txt. Without this file,
// this design will not compile. See Verilog
// LRM 1364-2001 Section 17.2.8 for details on the
// format of this file.
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31 module rom4096x18
#(parameter DATA_WIDTH=18, parameter ADDR_WIDTH=12)
(input clk,
// System clock
input reset,
// Asynchronous reset
input [(ADDR_WIDTH-1):0] address, // Address input
output reg [(DATA_WIDTH-1):0] q); // Data output
//==========================================================
// Declare the ROM variable
reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];
2
3
4
5
6
7
8
9
initial
begin
$readmemh("flash.mif", rom);
end
always @ (posedge clk or negedge reset)
if (reset)
q <= 0;
else
q <= rom[address];
endmodule