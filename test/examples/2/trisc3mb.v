// ===================================================================
// IEEE STD 1364-2001 Verilog file: trisc3mb.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
// ===================================================================
// Title: T-RISC 3 address machine
// Description: This is the top control path/FSM of the
// T-RISC, with a single 3 phase clock cycle design
// It has a stack 3-address type instruction word
// implementing a subset of the MicroBlaze architecture
// ===================================================================
module trisc3mb
(input clk,
// System clock
input reset,
// Asynchronous reset
input [0:7] in_port,
// Input port
output reg [0:7] out_port // Output port
// The following test ports are used for simulation only and should be
// comments during synthesis to avoid outnumbering the board pins
// output signed [0:31] r1_out, // Register 1
// output signed [0:31] r2_out, // Register 2
// output signed [0:31] r3_out, // Register 3
// output signed [0:31] r19_out, // Register 19 aka 2. stack pointer
// output signed [0:31] r14_out, // Register 14 aka return address
// output jc_out,
// Jump condition flag
// output me_ena,
// Memory enable
// output i_out,
// constant flag
// output [0:11] pc_out,
// Program counter
// output [0:15] ir_imm16, // Immediate value
// output [0:11] imm32_out, // Sign extend immediate value
// output [0:5]
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
wire [0:5] op;
wire [0:WD] ir, dmd, pmd, dma, pc4, branch_target;
reg [0:WD] pc, pc_d, target_delay; // PCs
wire mem_ena, not_clk;
wire jc, link, Dflag, cmp; // controller flags
reg go, Delay;
wire br, bra, bri, brai, condbr, condbri;// branch flags
wire swi, lwi, rt; // Special instr.
wire rAzero, rAnotzero, I, K, L, U, D6, D11;// flags
reg LI;



wire aai, aac, ooi, xxi; // Arith. instr.
wire imm, ld, st, load, store, read, write; // I/O flags
wire [0:4] D, A, B; // Register index
reg [0:4] T;
wire [0:WD] rA, rB, rD;// current Ops
wire [0:32] rAsxt, rBsxt, rDsxt; // Sign extended Ops
reg [0:15] rI; // 16 LSBs
wire [0:15] imm16, sxt16; // Total 32 bits
wire [0:WD] imm32; // 32 bit branch/mem/ALU
wire [0:32] imm33; // Sign extended ALU constant
reg C;
// Data RAM memory definition use one BRAM: DRAMAXx32
// Register array definition 16x32
reg [0:WD] r [0:NR];
reg [0:32] res;
assign rAzero = (rA==0)? 1'b1 : 1'b0; // rA=0
assign rAnotzero = (rA!=0)? 1'b1 : 1'b0; // rA/=0
always @* begin : P1 // Evaluation of signed condition
case (ir[8:10])
3'b000 :
go <= rAzero;
// BEQ =0
3'b001 :
go <= rAnotzero;
// BNE /=0
3'b010 :
go <= (rA[0]==1'b1);
// BLT < 0
3'b011 :
go <= (rA[0]==1'b1) || rAzero;
// BLE <=0
3'b100 :
go <= (rA[0]==1'b0) && rAnotzero; // BGT: > 0
3'b101 :
go <= (rA[0]==1'b0) || rAzero;
// BGE >=0
default:
go <= 1'b0;
// if not true
endcase
end
always @(negedge clk or negedge reset) // FSM of processor
begin : FSM // update the PC
if (~reset) begin // update the program counter
pc = 32'h00000000;
end else begin
// use falling edge
if (jc) begin
pc <= branch_target; // any current jumps
end else if (Delay) begin
pc <= target_delay; // any jumps with delay
end else begin
pc <= pc4; // Usual increment by 4 bytes
end
pc_d <= pc;
if (Dflag) Delay <= 1'b1;
else
Delay <= 1'b0;
target_delay <= branch_target; // store target address
end



end
assign pc4 = pc + 32'h00000004; // Default PC increment is 4 bytes
assign jc = ~Dflag && ((go && (condbr || condbri)) || br
|| bri || rt); // New PC; no delay?
assign branch_target = (bra) ? rB: // Order is important !
(brai)? imm32 :
(condbr || br)? pc + rB :
(rt)? rA + imm32 :
pc + imm32; // bri, condbri etc.
assign rt = (op==6'b101101)? 1'b1 : 1'b0; // return from
assign br = (op==6'b100110 )? 1'b1 : 1'b0; // always jump
assign bra = (br && ir[12]==1'b1)? 1'b1 : 1'b0;
assign bri = (op==6'b101110)? 1'b1 : 1'b0; //always jump w imm
assign brai = (bri && ir[12]==1'b1)? 1'b1 : 1'b0;
// link = bit 13 for br and bri
assign link = ((br || bri) && L )? 1'b1 : 1'b0; // save PC
assign condbr = (op==6'b100111)? 1'b1 : 1'b0; // cond. branch
assign condbri = (op==6'b101111)? 1'b1 : 1'b0; //cond. b/w imm
assign cmp = (op==6'b000101)? 1'b1 : 1'b0; // cmp and cmpu
// Mapping of the instruction, i.e., decode instruction
assign op
= ir[0:5];
// Data processing OP code
assign imm16 = ir[16:31];
// Immediate ALU operand
// Delay (D), Absolute (A) Decoder flags not used
assign I = ir[2]; // 2. op is imm
assign K = ir[3]; // K=1 keep carry
assign L = ir[13]; // Link for br and bri
assign U = ir[30]; // Unsigned flag
assign D6 = ir[6]; // Delay flag condbr/i;rt;
assign D11 = ir[11]; // Delay flag br/i
assign Dflag = (D6 && go && (condbr || condbri)) || (rt && D6) ||
(D11 && (br || bri)); // All Delay ops summary
// I = bit 2; K = bit; 3 add/addc/or/xor with(out) imm
assign aai = (ir[0:1]==2'b00 && ir[4:5]==2'b00)? 1'b1 : 1'b0;
assign aac = (ir[0:1]==2'b00 && ir[4:5]==2'b10)? 1'b1 : 1'b0;
assign ooi = (ir[0:1]==2'b10 && ir[3:5]==3'b000)? 1'b1 : 1'b0;
assign xxi = (ir[0:1]==2'b10 && ir[3:5]==3'b010)? 1'b1 : 1'b0;
// load and store:
assign ld = (ir[0:1]==2'b11 && ir[3:5]==3'b010)? 1'b1 : 1'b0;
assign st = (ir[0:1]==2'b11 && ir[3:5]==3'b110)? 1'b1 : 1'b0;
assign imm = (op==6'b101100)? 1'b1 : 1'b0;// always store imm
assign sxt16 = {16{imm16[0]}}; // Sign extend the constant
assign imm32 = (LI)? {rI, imm16} : // Immediate extend to 32
{sxt16, imm16}; // MSBs from last imm


assign
assign
assign
assign
assign
assign
register
A = ir[11:15]; // Index 1. source reg.
B = ir[16:20]; // Index 2. source register
D = ir[6:10]; // Index destination reg.
rA = r[A]; // First operand ALU
rAsxt = {rA[0], rA}; // Sign extend 1. operand
rB = (I)? imm32 : // 2. ALU operand maybe constant or
r[B];
// Second operand ALU
assign rBsxt = {rB[0], rB}; // Sign extend 2. operand
assign rD = r[D]; // Old destination register value
assign rDsxt = {rD[0], rD}; // Zero extend old value
rom4096x32 brom( // Instantiate a Block ROM
.clk(clk),
// System clock
.reset(reset), // Asynchronous reset
.address(pc[18:29]), // Program memory address 12 bits
.q(pmd));
// Program memory data
assign ir = pmd;
assign
assign
assign
assign
assign
assign
assign
dma = (I)? rA + imm32
store = st && (dma <=
load = ld && (dma <=
write = st && (dma >
read = ld && (dma >
mem_ena = store;
not_clk = ~ clk;
: rA + rB;
DRAMAX4); // DRAM store
DRAMAX4); // DRAM load
DRAMAX4); // I/O write
DRAMAX4); // I/O read
// Active for store only
data_ram bram ( // Use one BRAM: 4096x32
.clk(not_clk), // Write to RAM at falling clk edge
.address(dma[18:29]),
.q(dmd),
.data(rD),
.we(mem_ena)); // Read from RAM at falling clk edge
always @(*)
begin : P3
res = rDsxt; // keep old/default
if (aai) res = rAsxt + rBsxt;
if (aac) res = rAsxt + rBsxt + C;
if (ooi) res = rAsxt || rBsxt;
if (xxi) res = rAsxt ^ rBsxt;
if (cmp) begin res = rBsxt - rAsxt; // ok for signed
if (U) begin // unsigned special case
if ({1'b0, rA} > {1'b0, rB}) res[1] = 1'b1;
else
res[1] = 1'b0;
end
end




if (load) res = dmd;
if (read) res = {24'h000000,
end
487
in_port};
// Update flags and registers ============================
always @(posedge clk or negedge reset)
begin : P4
integer k;
// Temporary counter
if (~reset)
// Asynchronous clear
begin
LI <= 1'b0; C <= 1'b0; rI <= 32'h00000000;
for (k=0; k<32; k=k+1) r[k] <= k;
out_port <= 8'h00;
end
else begin
if (~K) begin // Compute new C flag for add if Keep=false
if ((res[0] == 1'b1) && (aai || aac)) C <= 1'b1;
else
C <= 1'b0;
end
// Compute and store new register values
if (imm) begin // Set flag: last was imm operation
rI <= imm16; LI <= 1'b1;
end else begin
rI <= 16'h0000; LI <= 1'b0;
end
if (D>0) begin // Do not write r(0)
if (link) begin // Store LR for operation branch with link aka
call
r[D] <= pc_d; // Old pc + 1 op after return
end else begin
r[D] <= res[1:32]; // Store ALU result
end
end
if (write) out_port <= rD[24:31]; // LSBs on the right
end
end
// // Extra test pins:
// assign pc_out = pc[20:31];
// assign ir_imm16 = imm16;
// assign op_code = op; // Data processing ops
// assign jc_out = jc;
// assign i_out = I;
// assign me_ena = mem_ena; // Control wires
// assign r1_out = r[1]; // First two user registers
// assign r2_out = r[2]; assign r3_out = r[3]; // Next two user
registers
// assign r15_out = r[15]; assign r19_out = r[19]; // Compiler
registers
endmodule