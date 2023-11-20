// ==============================================================
// File is True Dual Port RAM with dual clock for DRAM and ROM
// Copyright (C) 2019 Dr. Uwe Meyer-Baese.
// ==============================================================
module dpram4Kx32
(input clk_a,
// System clock DRAM
input clk_b,
// System clock PROM
input [11:0] addr_a,
// Data memory address
input [11:0] addr_b,
// Program memory address
input [31:0] data_a,
// Data in for DRAM
input we_a,
// Write only DRAM
output reg [31:0] q_a, // DRAM output
output reg [31:0] q_b); // ROM output
// ==============================================================
// Build a 2-D array type for the RAM
reg [31:0] dram[4095:0];
initial
begin
$readmemh("flash_arm.mif", dram);
end
// Port A aka DRAM
always @(posedge clk_a)
if (we_a) begin
dram[addr_a] <= data_a;
q_a <= data_a;
end else
q_a <= dram[addr_a];
// Port B aka ROM
always @(posedge clk_b)
q_b <= dram[addr_b];
endmodule