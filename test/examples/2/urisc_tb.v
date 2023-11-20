// Set reference time to 1 ns and precision to 1 ps
`timescale 1 ns / 1 ps
// ========================================================
module urisc_tb;
// ========================================================
// ========= Signal definition no initial values: =========
reg clk;
// System clock
reg reset;
// Asynchronous reset
reg [7:0] in_port;
// Input port
wire [7:0] out_port;
// Output port
parameter T = 20; // Simulation tick in ns
// ========= Unit under test instantiation: =========
urisc UUT(
.clk(clk),
.reset(reset),
.in_port(in_port),
.out_port(out_port));
// ========= Periodic signals: ============================
initial begin
clk = 0;
forever #(T/2) clk = ~clk;
end
// ================== Add stimuli: ========================
initial begin
reset = 1;
in_port = 5;
#105; // Time=105 ns
reset = 0;
#645; // Time=750 ns
end
endmodule