// ===================================================================
// IEEE STD 1364-2001 Verilog file: trisc3a.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
// ===================================================================
// Title: T-RISC 3 address machine
// Description: This is the top control path/FSM of the
// T-RISC, with a single 3 phase clock cycle design
// It has a 3-address type instruction word
// implementing a subset of the ARMv7 Cortex A9 architecture
// ===================================================================
module trisc3a
(input clk,
// System clock
input reset,
// Asynchronous reset
input [7:0] in_port,
// Input port
output reg [7:0] out_port // Output port
// The following test ports are used for simulation only and should be
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
47
48
49
50
51
52 // comments during synthesis to avoid outnumbering the board pins
// output signed [31:0] r0_out,
// Register 0
// output signed [31:0] r1_out,
// Register 1
// output signed [31:0] r2_out,
// Register 2
// output signed [31:0] r3_out,
// Register 3
// output signed [31:0] sp_out,
// Register 13 aka stack pointer
// output signed [31:0] lr_out,
// Register 14 aka link register
// output jc_out,
// Jump condition flag
// output me_ena,
// Memory enable
// output i_out,
// Constant flag
// output [11:0] pc_out,
// Program counter
// output [11:0] ir_imm12, // Immediate value
// output [31:0] imm32_out, // Sign extend immediate value
// output [3:0] op_code
// Operation code
);
// ===================================================================
// Define GENERIC to CONSTANT for _tb
parameter WA = 11; // Address bit width -1
parameter NR = 15; // Number of Registers -1; PC is extra
parameter WD = 31;
// Data bit width -1
parameter DRAMAX = 12'd4095; // No. of DRAM words -1
parameter DRAMAX4 = 30'd1073741823; // X"3FFFFFFF";
// True DDR RAM bytes -1
wire [3:0] op;
wire [WD:0] dmd, pmd, dma;
wire [3:0] cond;
wire [WD:0] ir, pc, pc_dd, pc4, pc8, branch_target;
reg [WD:0] tpc, pc4_d;
wire mem_ena, not_clk;
wire jc, dp, rlsl; // jump and decoder flags
wire I, set, P, U, bx, W, L; // Decoder flags
wire movt, movw, str, ldr, branch, bl; // Special instr.
wire load, store, read, write, pop, push; // I/O flags
wire popA1, pushA1, popA2, pushA2; // LDR/STM instr.
reg popPC, go;


reg [3:0] ind, ind_d; // push/pop index
reg N, Z, C, V; // reg flags
wire [3:0] D, NN, M; // Register index
wire [31:0] Rd, Rdd, Rn, Rm, r_m; // current Ops
reg [31:0] r_s;
wire [32:0] Rd1, Rn1, Rm1; // Sign extended Ops
wire [3:0] imm4; // imm12 extended
wire [4:0] imm5; // Within Op2
wire [11:0] imm12; // 12 LSBs
wire [19:0] sxt12; // Total 32 bits
wire [23:0] imm24; // 24 LSBs
wire [5:0] sxt24; // Total 30 bits
wire [WD:0] bimm32, imm32, mimm32; // 32 bit branch/mem/ALU
wire [32:0] imm33; // Sign extended ALU constant
// OP Code of instructions:
// The 4 bit for all data processing instructions
parameter opand = 4'h0, eor = 4'h1, sub = 4'h2, rsb = 4'h3, add =
4'h4,
adc = 4'h5, sbc = 4'h6, rsc = 4'h7, tst = 4'h8, teq = 4'h9, cmp =
4'hA,
cmn = 4'hB, orr = 4'hC, mov = 4'hD, bic = 4'hE, mvn = 4'hF;
// Register array definition 16x32
reg [WD:0] r [0:NR];
reg [32:0] res;
always @* begin : P1 // Evaluation of condition bits
case (ir[31:28]) // Shift value 2. operand ALU
4'b0000 : go <= Z;
// Zero: EQ or NE
4'b0001 : go <= ~Z;
4'b0010 : go <= C;
// Carry: CS or CC
4'b0011 : go <= ~C;
4'b0100 : go <= N;
// Negative: MI or PL
4'b0101 : go <= ~N;
4'b0110 : go <= V;
// Overflow: Vs or VC
4'b0111 : go <= ~V;
// Overflow: Vs or VC
4'b1000 : go <= C && ~Z;
// HI
4'b1001 : go <= ~C && Z;
// LS
4'b1010 : go <= (N==V);
// GE
4'b1011 : go <= (N!=V);
// LT
4'b1100 : go <= ~Z && (N==V); // GT
4'b1101 : go <= Z && (N!=V);
// LE
default : go <= 1'b1;
// Always
endcase
end
always @* begin : P2
integer i;
// Temporary counter
ind <= 0;
for (i=0;i<=NR;i=i+1)
if (ir[i] == 1'b1) ind <= i;
end



always @(negedge clk or negedge reset) // FSM of processor
begin : P3
if (~reset) begin // update the program counter
tpc <= 0; pc4_d <= 0; popPC <= 0;
end else begin
// use falling edge
if (jc)
tpc <= branch_target;
else begin
tpc <= pc4;
end
pc4_d <= pc4;
popPC <= 0;
if ((popA1 && ind==15) || (popA2 && D==15))
popPC <= 1; // Last op= pop PC ?
end
end
// true PC in dmd register if last op is pop AND ind=15
assign pc = (popPC)? dmd : tpc;
assign pc4 = pc + 32'h00000004; // Default PC increment is 4 bytes
assign pc8 = pc + 32'h00000008; // 2 OP PC increment is 8 bytes
assign jc = go && (branch||bl||bx|| (pop && ind==15)); // New PC?
assign sxt24 = {6{imm24[13]}}; // Sign extend the constant
assign bimm32 = {sxt24, imm24, 2'b00}; // Immediate for branch
assign branch_target = (bx)? r_m:bimm32 + pc8;//Jump are PC relative
// Mapping of the instruction, i.e., decode instruction
assign op
= ir[24:21]; // Data processing OP code
assign imm4 = ir[19:16]; // imm12 extended
assign imm5 = ir[11:7]; // The shift values of Op2
assign imm12 = ir[11:0]; // Immediate ALU operand
assign imm24 = ir[23:0]; // Jump address
// P, B, W Decoder flags not used
assign set = (ir[20])? 1'b1 : 1'b0; // update flags for S=1
assign I = (ir[25])? 1'b1 : 1'b0;
assign L = (ir[20])? 1'b1 : 1'b0; // L=1 load L=0 store
assign U = (ir[23])? 1'b1 : 1'b0; // U=1 add offset
assign movt = (ir[27:20] == 8'b00110100)? 1'b1 : 1'b0;
assign movw = (ir[27:20] == 8'b00110000)? 1'b1 : 1'b0;
assign branch = (ir[27:24] == 4'b1010)? 1'b1 : 1'b0;
assign bl = (ir[27:24] == 4'b1011)? 1'b1 : 1'b0;
assign bx = (ir[27:20] == 8'b00010010)? 1'b1 : 1'b0;
assign ldr = (ir[27:26] == 2'b01 && L)? 1'b1 : 1'b0; // load
assign str = (ir[27:26] == 2'b01 && ~L)? 1'b1 : 1'b0; // store
assign popA1 = (ir[27:16] == 12'b100010111101)? 1 : 0;
assign popA2 = (ir[27:16] == 12'b010010011101)? 1 : 0;
assign pop = popA1 || popA2;
// load multiple (A1) or one (A2) update sp-4 after memory access
assign pushA1 = (ir[27:16] == 12'b100100101101)? 1'b1 : 1'b0;
assign pushA2 = (ir[27:16] == 12'b010100101101)? 1'b1 : 1'b0;
assign push = pushA1 || pushA2;
// store multiple (A1) or one (A2) update sp+4 before memory access
assign dp = (ir[27:26] == 2'b00)? 1'b1 : 1'b0; // data processing
assign
assign
assign
assign
NN
M
D
Rn
=
=
=
=
ir[19:16]; // Index 1. source reg.
ir[3:0]; // Index 2. source register
ir[15:12]; // Index destination reg.
r[NN]; // First operand ALU



assign Rn1 = {Rn[31], Rn}; // Sign extend 1. operand by 1 bit
assign r_m = r[M];
assign rlsl = (ir[6:4] == 3'b000)? 1'b1 : 1'b0; //Shift left reg.
// determine the 2 register operand
always @*
case (imm5) // Shift value 2. operand ALU
5'b00001 : r_s <= {r_m[30:0], 1'b0}; // LSL=1
5'b00010 : r_s <= {r_m[29:0], 2'b00}; // LSL=2
default : r_s <= r_m;
endcase
assign Rm = (I) ? imm32 : r_s; // 2. ALU operand maybe constant or
register
assign Rm1 = {Rm[31], Rm}; // Sign extend 2. operand by 1 bit
assign Rd = r[D]; // Old destination register value
assign Rd1 = {Rd[31], Rd}; // Sign extend old value by 1 bit
assign mimm32 = {sxt12, imm12}; // memory immediate
assign dma = (I)? Rn + Rm :
(push)? r[13] - 4 : // use sp
(pop)? r[13] :
// use sp
(U && NN!=15)? Rn + mimm32 :
(~U && NN!=15)? Rn - mimm32 :
(U && NN==15)? pc8 + mimm32 : // PC-relative is special
pc8 - mimm32;
assign store = (str || push) && (dma <= DRAMAX4); // DRAM store
assign load = (ldr || pop) && (dma <= DRAMAX4); // DRAM load
assign write = str && (dma > DRAMAX4); // I/O write
assign read = ldr && (dma > DRAMAX4); // I/O read
assign mem_ena = (store) ? 1'b1 : 1'b0; // Active for store only
assign Rdd = (pushA1)? r[ind] : Rd;
assign not_clk = ~clk;
// ARM PC-relative ops require True Dual Port RAM with dual clock
dpram4Kx32 mem // Instantiate a Block DRAM and ROM
(
.clk_a(not_clk), // System clock DRAM
.clk_b(clk), // System clock PROM
.addr_a(dma[13:2]), // Data memory address 12 bits
.addr_b(pc[13:2]), // Program memory address 12 bits
.data_a(Rdd), // Data in for DRAM
.we_a(mem_ena), // Write only DRAM
.q_a(dmd), // Data RAM output
.q_b(pmd)); // Program memory data
assign ir = pmd;
// ALU imm computations:
assign sxt12 = {20{imm12[11]}}; // Sign extend the constant
assign imm32 = (movt)? {imm4, imm12, Rd[15:0]} :
(movw)? {16'h0000, imm4, imm12} :
{sxt12, imm12}; // Place imm16 in MSBs for movt



assign imm33 = {imm32[31], imm32}; // sign extend constant
always @(*)
begin : P4
res <= Rd1;
if (dp)
case (op)
opand :
eor
:
sub
:
rsb
:
add
:
adc
:
sbc
:
rsc
:
tst
:
teq
cmp
:
:
// Default old value
res <= Rn1 & Rm1;
res <= Rn1 ^ Rm1;
res <= Rn1 - Rm1;
res <= Rm1 - Rn1;
res <= Rn1 + Rm1;
res <= Rn1 + Rm1 + C;
res <= Rn1 - Rm1 + C -1;
res <= Rm1 - Rn1 + C -1;
if (movw) res <= imm33; else
res <= Rn1 & Rm1;
res <= Rn1 ^ Rm1;
if (movt) res <= imm33; else
res <= Rn1 - Rm1;
res <= Rn1 + Rm1;
res <= Rn1 | Rm1;
res <= Rm1;
res <= Rn1 & ~Rm1;
res <= ~Rm1;
: res <= Rd1;
cmn
:
orr
:
mov
:
bic
:
mvn
:
default
endcase
if (load || pop) res <= { 1'b0, dmd};
if (read) res <= {25'h0000000, in_port};
end
//=========== Update flags and registers ============================
always @(posedge clk or negedge reset)
begin : P5
integer k;
// Temporary counter
if (~reset) begin
// Asynchronous clear
Z <= 1'b0; C <= 1'b0; N <= 1'b0; V <= 1'b0;
out_port <= 8'h00;
for (k=0; k<16; k=k+1) r[k] <= k;
end
else begin // ARMv7 has 4 flags
if (dp && set) begin // set flags N and Z for all 16 OPs
if (res[31] == 1'b1) N <= 1'b1; else N <= 1'b0;
if (res[31:0] == 32'h00000000) Z <= 1'b1; else Z <=1'b0;
if ((res[32] == 1'b1) && (op != mov)) C <= 1'b1; else C
<=1'b0;
// ========== Compute new C flag except of MOV ======================
if ((res[32] != res[31]) && ((op == sub) || (op == rsb) ||
(op == add) || (op == adc) || (op == sbc) || (op == rsc) ||



(op == cmp) || (op == cmn))) V <= 1'b1; else V <= 1'b0;
// Compute new overflow flag for arith. ops
end
if (bl) // Store LR for operation branch with link aka call
r[14] <= pc4_d; // Old pc + 1 op after return
else if (push)
r[13] <= r[13] - 4;
else if (read || load || movw || movt || (dp &&
(op != tst) && (op != teq ) && ( op != cmp ) && (op != cmn)))
begin
r[D] <= res[31:0]; // Store ALU result (not for test ops)
if (popA1 && (ind != 13)) begin
r[13] <= r[13] + 4;
r[ind] <= res[31:0];
end
if (popA2 && (D != 13)) begin
r[D] <= res[31:0];
r[13] <= r[13] + 4;
end
end
out_port = (write) ? Rd[7:0] : out_port;
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
//
//
-- Extra test pins:
assign pc_out <= pc[11:0];
assign ir_imm12 <= imm12;
assign imm32_out <= imm32;
assign op_code <= op; // Data processing ops
assign jc_OUT <= jc;
i_OUT <= I;
me_ena <= mem_ena; // Control wires
r0_out <= r[0]; r1_out <= r[1]; // First two user registers
r2_out <= r[2]; r3_out <= r[3]; // Next two user registers
sp_out <= r[13]; lr_out <= r[14]; // Compiler registers
endmodule