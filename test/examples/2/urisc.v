// ========================================================
// IEEE STD 1364-2001 Verilog file: urisc.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
// ========================================================
// Title: URISC microprocessor
// Description: This is the top control path/FSM of the
// URISC, with a 3 state machine design
// ========================================================
module urisc
(input clk,
//
input reset,
//
input [7:0] in_port,
//
output reg [7:0] out_port);//
System clock
Active low asynchronous reset
Input port
Output port
// ========================================================
// FSM States:
parameter FE=0, DC=1, EX=2;
reg [1:0] state;
// Register array definition
reg [7:0] r [15:0];
// Local signals
wire [15:0] data;
reg [15:0] ir;
reg mode;
wire jump;
reg [3:0] rd, rs;
reg [6:0] address, pc;
wire [7:0] dif;
reg [8:0] result;
rom128x16 prog_rom
( .clk(clk),
.address(pc),
.data(data));
//
//
//
//
Instantiate the LUT
System clock
Program memory address
Program memory data
always @(posedge clk or negedge reset) //PSM w/ ROM behavioral style
begin : States
// URISC in behavioral style
integer k;
// Temporary counter
if (~reset) begin
// all set register to -1
state <= FE;
for (k=1; k<=15; k=k+1) r[k] = -1;
pc <= 0;
end else begin
// use rising edge
case (state)
FE: begin
// Fetch instruction
ir <= data; // Get the 16-bit instruction
state <= DC;
end


DC: begin
// Decode instruction; split ir
rd <= ir[15:12]; // MSB has destination
rs <= ir[11:8];// second source operand
mode <= ir[7]; // flag for address mode
address <= ir[6:0]; // next PC value
state <= EX;
end
EX: begin
// Process URISC instruction
result = {r[rd][7], r[rd] } - {r[rs][7], r[rs] };
if (rd>0) r[rd] <= result[7:0];// do not write input port
if (~result[8]) begin pc <= pc + 1;//test is false inc PC
end else begin // result was negative
if (mode) pc <= address; //absolute addressing mode
else pc <= pc + address; //relative addressing mode
end
r[0] <= in_port;
out_port <= r[15];
state <= FE;
end
default : state <= FE;
endcase
end
// Extra test pins:
assign jump = result[8];
assign dif = result[7:0];
endmodule