// ===================================================================
// IEEE STD 1364-2001 Verilog file: trisc3n.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
// ===================================================================
// Title: T-RISC 3 address machine
// Description: This is the top control path/FSM of the
// T-RISC, with a single 3 phase clock cycle design
// It has a stack 3-address type instruction word
// ===================================================================
module trisc3n
(input clk,
// System clock
input reset,
// Asynchronous reset
input [7:0] in_port,
// Input port
output reg [7:0] out_port // Output port
// The following test ports are used for simulation only and should be
// comments during synthesis to avoid outnumbering the board pins
// output signed [31:0] r1_out,
// Register 1
// output signed [31:0] r2_out,
// Register 2
// output signed [31:0] r3_out,
// Register 3
// output signed [31:0] r4_out,
// Register 4
// output signed [31:0] sp_out,
// Register 27 aka stack pointer
// output signed [31:0] ra_out,
// Register 31 aka return address
// output jc_out,
// Jump condition flag
// output me_ena,
// Memory enable
// output k_out,
// constant flag
// output [11:0] pc_out,
// Program counter
// output [15:0] ir_imm16, // Immediate value
// output [11:0] imm32_out, // Sign extend immediate value
// output [5:0]
op_code
// Operation code
);
// ===================================================================
// Define GENERIC to CONSTANT for _tb
parameter WA = 4'd11; // Address bit width -1
parameter NR = 5'd31;
// Number of Registers -1
parameter WD = 5'd31;
// Data bit width -1
parameter DRAMAX = 12'd4095; // No. of DRAM words -1
parameter DRAMAX4 = 14'd16383; // No. of DRAM bytes -1
wire [5:0] op, opx;
wire [WD:0] dmd, pmd, dma;
wire [4:0] imm5;
wire [15:0] sxti, imm16;
wire [25:0] imm26;
wire [WD:0] imm32;
wire [4:0] A, B, C;
wire [WD:0] rA, rB, rC;
reg [WD:0] branch_target, pc, pc8;// PCs
wire [WD:0] ir, pc4, pcimm26;// PCs
wire eq, ne, mem_ena, not_clk;
wire jc, kflag; // jump and imm flags
wire load, store, read, write; // I/O flags
// Register array definition 32x32
reg [WD:0] r [0:NR];
reg [WD:0] res;
//Data RAM memory definition within component



// OP Code of instructions:
// The 6 LSBs IW for all implemented operations sorted by op code
parameter
call = 6'h00, jmpi = 6'h01, addi = 6'h04, br = 6'h06, andi = 6'h0C,
ori = 6'h14, stw = 6'h15, ldw = 6'h17, xori = 6'h1C, bne = 6'h1E,
beq = 6'h26, orhi = 6'h34, stwio = 6'h35, ldwio = 6'h37,
R_type = 6'h3A;
// 6 bits for OP eXtented instruction with OP=3A=111010
parameter
ret = 6'h05, jmp = 6'h0D, opand = 6'h0E, opor = 6'h16,
opxor = 6'h1E, add = 6'h31, sub = 6'h39;
always @(negedge clk or negedge reset)
if (~reset) begin // update the program counter
pc <= 0; pc8 <= 0;
end else begin
// use falling edge
if (jc)
pc <= branch_target;
else begin
pc <= pc4;
pc8 <= pc + 32'h00000008;
end
end
assign pc4 = pc + 4; // Default PC increment is 4 bytes
assign pcimm26 = {pc[31:28], imm26, 2'b00};
assign jc = (op==beq && rA==rB) || (op==jmpi) || (op==br)
|| (op==bne && rA!=rB) || (op==call)
|| (op==R_type && (opx==ret || opx==jmp));
always @* begin
if (op==jmpi || op==call) branch_target = pcimm26; else
if (op==R_type && opx==ret) branch_target = r[31]; else
if (op==R_type && opx==jmp) branch_target = rA; else
branch_target = imm32+pc4; // WHEN (op=beq OR op=bne OR op=br)
end
// Mapping of the instruction, i.e., decode instruction
assign op = ir[5:0];
// Operation code
assign opx = ir[16:11];
// OPX code for ALU ops
assign imm5 = ir[10:6];
// OPX constant
assign imm16 = ir[21:6];
// Immediate ALU operand
assign imm26 = ir[31:6];
// Jump address
assign A = ir[31:27]; // Index 1. source reg.
assign B = ir[26:22]; // Index 2. source/des. register
assign C = ir[21:17];// Index destination reg.
assign rA = r[A]; // First source ALU
assign rB = (kflag) ? imm32 : r[B]; // Second source ALU
assign rC = r[C]; // Old destination register value
// Immediate flag 0= use register 1= use HI/LO extended imm16;
assign kflag = (op==addi) || (op==andi) || (op==ori) || (op==xori)
|| (op==orhi) || (op==ldw) ||



(op==ldwio);
assign sxti = {16{imm16[15]}}; // Sign extend the constant
assign imm32 = (op==orhi)? {imm16, 16'h0000} :
{sxti, imm16}; // Place imm16 in MSbs for ..hi
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
137
138
139
140
141
142
143
144
145
146
147
148
149
150
151
152
153
154
155
156
157
158
159
160
161
162 assign dma = rA + imm32;
assign store = ((op==stw) || (op==stwio)) && (dma <= DRAMAX4);//
DRAM store
assign load = ((op==ldw) || (op==ldwio)) && (dma <= DRAMAX4); //
DRAM load
assign write = ((op==stw) || (op==stwio)) && (dma > DRAMAX4); // I/O
write
assign read = ((op==ldw) || (op==ldwio)) && (dma > DRAMAX4); // I/O
read
assign not_clk = ~clk;
assign mem_ena = (store) ? 1 : 0; // Active for store only
data_ram bram
( .clk(not_clk),.address(dma[13:2]), .q(dmd),
.data(rB), .we(mem_ena));
rom4096x32 brom
( .clk(clk), .reset(reset), .address(pc[13:2]), .q(pmd));
assign ir = pmd;
always @(*)
begin : P3
res = rC; // keep old/default
if ((op==R_type && opx==add) || (op==addi)) res = rA + rB;
if (op==R_type && opx==sub) res = rA - rB;
if ((op==R_type && opx==opand) || (op==andi)) res = rA & rB;
if ((op==R_type && opx==opor) || (op==ori) || (op==orhi))
res = rA | rB;
if ((op==R_type && opx==opxor) || (op==xori)) res = rA ^ rB;
if (load) res = dmd;
if (read) res = {24'h000000, in_port};
end
always @(posedge clk or negedge reset)
begin : P4
integer k;
// Temporary counter
if (~reset)
// Asynchronous clear
begin
for (k=0; k<32; k=k+1) r[k] <= 0;
out_port <= 0;
end
else
begin
if (op==call) // Store ra for operation call
r[31] <= pc8; // Old pc + 1 op after return
else
begin if (kflag && B>0) // All I-type
begin
r[B] <= res;
end else begin



if (C > 0) r[C] <= res;
end
end
out_port = (write) ? rB[7:0] : out_port;
end
end
// Extra test pins:
// assign pc_out = pc[11:0]; assign ir_imm16 = imm16;
// assign imm32_out = imm32;
// assign op_code = op; // Program control
// // Control signals:
// assign jc_out = jc; assign me_ena = mem_ena;
// assign k_out = kflag;
// // Two top stack elements:
// assign r1_out = r[1]; assign r2_out = r[2]; // First two user
registers
// assign r3_out = r[3]; assign r4_out = r[4]; // Next two user
registers
// assign sp_out = r[27]; assign ra_out = r[31]; // Compiler
registers
endmodule