//==========================================================
// IEEE STD 1364-2001 Verilog file: trisc2.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//==========================================================
// Title: T-RISC 2 address machine
// Description: This is the top control path/FSM of the
// T-RISC, with a single 3 phase clock cycle design
// It has a stack 2-address type instruction word
// =========================================================
module trisc2
(input clk,
// System clock
input reset,
// Asynchronous reset
input [7:0] in_port,
// Input port
output reg [7:0] out_port // Output port
// The following test ports are used for simulation only and should be
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
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47 // comments during synthesis to avoid outnumbering the board pins
// output signed [7:0] s0_out,
// Register 0
// output signed [7:0] s1_out,
// Register 1
// output signed [7:0] s2_out,
// Register 2
// output signed [7:0] s3_out,
// Register 3
// output jc_out,
// Jump condition flag
// output me_ena,
// Memory enable
// output z_out,
// Zero flag
// output c_out,
// Carry flag
// output [11:0] pc_out,
// Program counter
// output [11:0] ir_imm12, // Immediate value
// output [5:0] op_code
// Operation code
);
// ==========================================================
2
3
4
5
6
7
8
9
10
11
12
13
14
wire [4:0] op5;
wire [5:0] op6;
wire [7:0] imm8, dmd, x, y;
wire [11:0] imm12;
wire [7+1:0] x0, y0;
reg [7:0] s [0:15];
reg [11:0] lreg [0:30];
reg [11:0] pc;
reg [4:0] lcount;
wire [11:0] pc1;
wire [11:0] dma;
wire [17:0] pmd, ir;
wire mem_ena, jc, not_clk, kflag;
reg z_new, c_new;
reg z, c;
reg [8:0] res;
wire [3:0] rd, rs;






// OP Code of instructions:
parameter
add
= 5'b01000,
addcy = 5'b01001,
sub
subcy = 5'b01101,
opand = 5'b00001,
opxor
opor = 5'b00010, opinput = 5'b00100, opoutput
store = 5'b10111,
fetch = 5'b00101,
load
jump = 6'b100010, jumpz = 6'b110010, jumpnz
call = 6'b100000, opreturn = 6'b100101;
471
=
=
=
=
=
5'b01100,
5'b00011,
5'b10110,
5'b00000,
6'b110110,
always @(negedge clk or negedge reset) begin : P1
if (~reset) begin // update the program counter
pc <= 0;
lcount <= 0;
end else begin
// use falling edge
if (op6 == call) begin
lreg[lcount] <= pc1; // Use next address after call/return
lcount <= lcount + 1;
end
if (op6 == opreturn) begin
pc <= lreg[lcount-1]; // Use next address after call/return
lcount <= lcount -1;
end
else if (jc)
pc <= imm12;
else
pc <= pc1;
end
end
assign pc1 = pc + 1;
assign jc = (op6==jumpz && z) || (op6==jumpnz && ~z)
|| (op6==jump) || (op6==call);
// Mapping of the instruction, i.e., decode instruction
assign op6 = ir[17:12]; // Full Operation code
assign op5 = ir[17:13]; // Reduced Op code for ALU ops
assign kflag = ir[12];
// Immediate flag 0=use register 1=use kk;
assign imm8 = ir[7:0];
// 8 bit immediate operand
assign imm12 = ir[11:0]; // 12 bit immediate operand
assign rd = ir[11:8];
// Index destination/1. source register
assign rs = ir[7:4];
// Index 2. source register
assign x = s[rd];
// first source ALU
assign x0 = {1'b0 , x}; // zero extend 1. source
assign y = (kflag) ? imm8 : s[rs]; // MPX second source ALU
assign y0 = {1'b0, y};
rom4096x18 brom
( .clk(clk), .reset(reset), .address(pc), .q(pmd));
assign ir = pmd;
assign not_clk = ~clk;
assign mem_ena = (op5 == store) ? 1 : 0;
data_ram bram
( .clk(not_clk),.address(y), .q(dmd),
.data(x), .we(mem_ena));




always @(*)
begin : P2
case (op5)
add
:
addcy
:
sub
:
subcy
:
opand
:
opor
:
opxor
:
res
res
res
res
res
res
res
=
=
=
=
=
=
=
x0
x0
x0
x0
x0
x0
x0
+
+
-
-
&
|
^
y0;
y0 + c;
y0;
y0 - c;
y0;
y0;
y0;
load
:
res = y0;
opinput :
res = {1'b0 , in_port};
fetch
:
res = {1'b0 , dmd};
default :
res = x0;
endcase
z_new = (res == 0) ? 1 : 0;
c_new = res[8];
end
always @(posedge clk or negedge reset)
begin : P3
if (~reset) begin
// Asynchronous clear
z <= 0; c <= 0; out_port <= 0;
end else begin
case (op5) // Specify the stack operations
addcy, subcy : begin z <= z & z_new;
c <= c_new; end
// carry from previous operation
add , sub : begin z <= z_new; c <= c_new; end
// No carry
opor , opand, opxor : begin z <= z_new; c <= 0; end
// No carry; c=0
default : begin z <= z; c <= c; end
// keep old
endcase
s[rd] <= res[7:0];
out_port = (op5 == opoutput) ? x : out_port;
end
end
//
//
//
//
//
//
//
//
//
// Extra test pins:
assign pc_out = pc; assign ir_imm12 = imm12;
assign op_code = op6; // Program control
// Control signals:
assign jc_out = jc; assign me_ena = mem_ena;
assign z_out = z; assign c_out = c; // ALU flags
// Two top stack elements:
assign s0_out = s[0]; assign s1_out = s[1];
assign s2_out = s[2]; assign s3_out = s[3];
endmodule