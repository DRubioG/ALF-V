-- ===================================================================
-- Title: T-RISC 3 address machine
-- Description: This is the top control path/FSM of the
-- T-RISC, with a single 3 phase clock cycle design
-- It has a 3-address type instruction word
-- implementing a subset of the MicroBlaze architecture
-- ===================================================================
LIBRARY ieee; USE ieee.std_logic_1164.ALL;
PACKAGE n_bit_type IS
-- User defined types
SUBTYPE U8 IS INTEGER RANGE 0 TO 255;
SUBTYPE U12 IS INTEGER RANGE 0 TO 4095;
SUBTYPE SLVA IS STD_LOGIC_VECTOR(0 TO 11); -- Address prog. mem.
SUBTYPE SLVD IS STD_LOGIC_VECTOR(0 TO 31); -- Width data
SUBTYPE SLVD1 IS STD_LOGIC_VECTOR(0 TO 32); -- Width data + 1
SUBTYPE SLVP IS STD_LOGIC_VECTOR(0 TO 31); -- Width instruction
SUBTYPE SLV6 IS STD_LOGIC_VECTOR(0 TO 5); -- Full opcode size
END n_bit_type;
LIBRARY work;
USE work.n_bit_type.ALL;
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_signed.ALL;
-- ===================================================================
ENTITY trisc3mb IS
PORT(clk
: IN STD_LOGIC; -- System clock
reset
: IN STD_LOGIC; -- Active low asynchronous reset
in_port : IN STD_LOGIC_VECTOR(0 TO 7); -- Input port
out_port : OUT STD_LOGIC_VECTOR(0 TO 7) -- Output port
-- The following test ports are used for simulation only and should be
-- comments during synthesis to avoid outnumbering the board pins
--
r1_OUT
: OUT SLVD; -- Register 1
--
r2_OUT
: OUT SLVD; -- Register 2
--
r3_OUT
: OUT SLVD; -- Register 3
--
r19_OUT
: OUT SLVD; -- Register 19 aka 2. stack pointer
--
r15_OUT
: OUT SLVD; -- Register 14 aka return address
--
jc_OUT
: OUT STD_LOGIC;
-- Jump condition flag
--
me_ena
: OUT STD_LOGIC;
-- Memory enable
--
i_OUT
: OUT STD_LOGIC;
-- constant flag
--
pc_OUT
: OUT STD_LOGIC_VECTOR(0 TO 11); -- Program counter
--
ir_imm16 : OUT STD_LOGIC_VECTOR(0 TO 15); -- Immediate value
--
imm32_out : OUT SLVD;
-- Sign extend immediate value
--
op_code : OUT STD_LOGIC_VECTOR(0 TO 5)
-- Operation code
);
END ENTITY;


-- ===================================================================
ARCHITECTURE fpga OF trisc3mb IS
-- Define GENERIC to CONSTANT for _tb
CONSTANT WA : INTEGER := 11; -- Address bit width -1
CONSTANT NR : INTEGER := 31; -- Number of Registers -1; PC is extra
CONSTANT WD : INTEGER := 31;
-- Data bit width -1
CONSTANT DRAMAX : INTEGER := 4095; -- No. of DRAM words -1
CONSTANT DRAMAX4 : INTEGER := 16384; -- X"4000";
-- True DRAM bytes -1
COMPONENT rom4096x32 IS
PORT (clk
: IN STD_LOGIC;
-- System clock
reset : IN STD_LOGIC;
-- Asynchronous reset
pma
: IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- Program mem. add.
pmd
: OUT STD_LOGIC_VECTOR(31 DOWNTO 0));--Program mem. data
END COMPONENT;
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
op : SLV6;
dmd, pmd, dma : SLVD;
ir, pc, pc4, pc_d, branch_target, target_delay : SLVP;-- PCs
mem_ena, not_clk : STD_LOGIC;
jc, go, link, Dflag, Delay, cmp : boolean;-- controller flags
br, bra, bri, brai, condbr, condbri : boolean;-- branch flags
swi, lwi, rt : boolean; -- Special instr.
rAzero, rAnotzero, I, K, L, U, LI, D6, D11 : boolean;-- flags
aai, aac, ooi, xxi : boolean; -- Arith instr.
imm, ld, st, load, store, read, write : boolean; -- I/O flags
D, A, B : INTEGER RANGE 0 TO 31; -- Register index
rA, rB, rD : SLVD := (OTHERS => '0');-- current Ops
rAsxt, rBsxt,
rDsxt : SLVD1; -- Sign extended Ops
rI, imm16 : STD_LOGIC_VECTOR(0 TO 15); -- 16 LSBs
sxt16 : STD_LOGIC_VECTOR(0 TO 15); -- Total 32 bits
imm32 : SLVD; -- 32 bit branch/mem/ALU
imm33 : SLVD1; -- Sign extended ALU constant
c : STD_LOGIC;
-- Data RAM memory definition use one BRAM: DRAMAXx32
TYPE MTYPE IS ARRAY(0 TO DRAMAX) OF SLVD;
SIGNAL dram : MTYPE;
-- Register array definition 16x32
TYPE REG_ARRAY IS ARRAY(0 TO NR) OF SLVD;
SIGNAL r : REG_ARRAY;
BEGIN
rAzero <= true WHEN (rA=0) ELSE false; -- rA=0
rAnotzero <= true WHEN (rA/=0) ELSE false; -- rA/=0
WITH ir(8 TO 10) SELECT -- Evaluation of signed condition

go <= rAzero
WHEN "000",
rAnotzero
WHEN "001",
rA(0)='1'
WHEN "010",
rA(0)='1' OR rAzero
WHEN "011",
rA(0)='0' AND rAnotzero WHEN "100",
rA(0)='0' OR rAzero
WHEN "101",
false
WHEN OTHERS; -- if not true
--
--
--
--
--
--
BEQ =0
BNE /=0
BLT < 0
BLE <=0
BGT: > 0
BGE >=0
FSM: PROCESS (reset, clk) -- FSM of processor
BEGIN -- update the PC
IF reset = '0' THEN
pc <= (OTHERS => '0');
ELSIF falling_edge(clk) THEN
IF jc THEN
pc <= branch_target ; -- any current jumps
ELSIF Delay THEN
pc <= target_delay ; -- any jumps with delay
ELSE
pc <= pc4; -- Usual increment by 4 bytes
END IF;
pc_d <= pc;
IF Dflag THEN Delay <= true;
ELSE
Delay <= false;
END IF;
target_delay <= branch_target; -- store target address
END IF;
END PROCESS FSM;
pc4 <= pc + X"00000004"; -- Default PC increment is 4 bytes
jc <= NOT Dflag AND ((go AND (condbr OR condbri)) OR br
OR bri or rt); -- New PC; no delay?
branch_target <= rB WHEN bra -- Order is important !
ELSE imm32 WHEN brai
ELSE pc + rB WHEN condbr OR br
ELSE rA + imm32 WHEN rt
ELSE pc + imm32; -- bri, condbri etc.
rt <= true WHEN op= "101101" ELSE false; -- return from
br <= true WHEN op= "100110" ELSE false; -- always jump
bra <= true WHEN br AND ir(12)='1' ELSE false;
bri <= true WHEN op= "101110" ELSE false;--always jump w imm
brai <= true WHEN bri AND ir(12)='1' ELSE false;
-- link = bit 13 for br and bri
link <= true WHEN (br OR bri) AND L ELSE false; -- save PC
condbr <= true WHEN op= "100111" ELSE false;-- cond. branch
condbri <= true WHEN op= "101111" ELSE false;--cond. b/w imm
cmp <= true WHEN op= "000101" ELSE false; -- cmp and cmpu
-- Mapping of the instruction, i.e., decode instruction



op
<= ir(0 TO 5);
-- Data processing OP code
imm16 <= ir(16 TO 31);
-- Immediate ALU operand
-- Delay (D), Absolute (A) Decoder flags not used
I <= true WHEN ir(2)='1' ELSE false; -- 2. op is imm
K <= true WHEN ir(3)='1' ELSE false; -- K=1 keep carry
L <= true WHEN ir(13)='1' ELSE false; -- Link for br and bri
U <= true WHEN ir(30)='1' ELSE false; -- Unsigned flag
D6 <= true WHEN ir(6)='1' ELSE false; -- Delay flag condbr/i;rt;
D11 <= true WHEN ir(11)='1' ELSE false; -- Delay flag br/i
Dflag <= (D6 AND go AND (condbr OR condbri)) OR (rt AND D6) OR
(D11 AND (br OR bri)); -- All Delay ops summary
-- I = bit 2; K = bit; 3 add/addc/or/xor with(out) imm
aai <= true WHEN ir(0 TO 1)= "00" AND ir(4 TO 5)= "00" ELSE false;
aac <= true WHEN ir(0 TO 1)= "00" AND ir(4 TO 5)= "10" ELSE false;
ooi <= true WHEN ir(0 TO 1)= "10" AND ir(3 TO 5)= "000" ELSE false;
xxi <= true WHEN ir(0 TO 1)= "10" AND ir(3 TO 5)= "010" ELSE false;
-- load and store:
ld <= true WHEN ir(0 TO 1)= "11" AND ir(3 TO 5)= "010" ELSE false;
st <= true WHEN ir(0 TO 1)= "11" AND ir(3 TO 5)= "110" ELSE false;
imm <= true WHEN ir(0 TO 5)= "101100" ELSE false;-- always store imm
sxt16 <= (OTHERS => imm16(0)); -- Sign extend the constant
imm32 <= rI & imm16 WHEN LI -- Immediate extend to 32
ELSE sxt16 & imm16; -- MSBs from last imm
A <= CONV_INTEGER('0' & ir(11 TO 15)); -- Index 1. source reg.
B <= CONV_INTEGER('0' & ir(16 TO 20));-- Index 2. source register
D <= CONV_INTEGER('0' & ir(6 TO 10));-- Index destination reg.
rA <= r(A); -- First operand ALU
rAsxt <= rA(0) & rA; -- Sign extend 1. operand
rB <= imm32 WHEN I -- 2. ALU operand maybe constant or register
ELSE r(B);
-- Second operand ALU
rBsxt <= rB(0) & rB; -- Sign extend 2. operand
rD <= r(D); -- Old destination register value
rDsxt <= rD(0) & rD; -- Sign extend old value
prog_rom: rom4096x32
-- Instantiate a Block ROM
PORT MAP (clk
=> clk,
-- System clock
reset => reset, -- Asynchronous reset
pma
=> pc(18 TO 29),-- Program memory address 12 bits
pmd
=> pmd);
-- Program memory data
ir <= pmd;
dma <= rA + imm32 WHEN I
ELSE rA + rB;
store <= st AND (dma <= DRAMAX4); -- DRAM store



op
<= ir(0 TO 5);
-- Data processing OP code
imm16 <= ir(16 TO 31);
-- Immediate ALU operand
-- Delay (D), Absolute (A) Decoder flags not used
I <= true WHEN ir(2)='1' ELSE false; -- 2. op is imm
K <= true WHEN ir(3)='1' ELSE false; -- K=1 keep carry
L <= true WHEN ir(13)='1' ELSE false; -- Link for br and bri
U <= true WHEN ir(30)='1' ELSE false; -- Unsigned flag
D6 <= true WHEN ir(6)='1' ELSE false; -- Delay flag condbr/i;rt;
D11 <= true WHEN ir(11)='1' ELSE false; -- Delay flag br/i
Dflag <= (D6 AND go AND (condbr OR condbri)) OR (rt AND D6) OR
(D11 AND (br OR bri)); -- All Delay ops summary
-- I = bit 2; K = bit; 3 add/addc/or/xor with(out) imm
aai <= true WHEN ir(0 TO 1)= "00" AND ir(4 TO 5)= "00" ELSE false;
aac <= true WHEN ir(0 TO 1)= "00" AND ir(4 TO 5)= "10" ELSE false;
ooi <= true WHEN ir(0 TO 1)= "10" AND ir(3 TO 5)= "000" ELSE false;
xxi <= true WHEN ir(0 TO 1)= "10" AND ir(3 TO 5)= "010" ELSE false;
-- load and store:
ld <= true WHEN ir(0 TO 1)= "11" AND ir(3 TO 5)= "010" ELSE false;
st <= true WHEN ir(0 TO 1)= "11" AND ir(3 TO 5)= "110" ELSE false;
imm <= true WHEN ir(0 TO 5)= "101100" ELSE false;-- always store imm
sxt16 <= (OTHERS => imm16(0)); -- Sign extend the constant
imm32 <= rI & imm16 WHEN LI -- Immediate extend to 32
ELSE sxt16 & imm16; -- MSBs from last imm
A <= CONV_INTEGER('0' & ir(11 TO 15)); -- Index 1. source reg.
B <= CONV_INTEGER('0' & ir(16 TO 20));-- Index 2. source register
D <= CONV_INTEGER('0' & ir(6 TO 10));-- Index destination reg.
rA <= r(A); -- First operand ALU
rAsxt <= rA(0) & rA; -- Sign extend 1. operand
rB <= imm32 WHEN I -- 2. ALU operand maybe constant or register
ELSE r(B);
-- Second operand ALU
rBsxt <= rB(0) & rB; -- Sign extend 2. operand
rD <= r(D); -- Old destination register value
rDsxt <= rD(0) & rD; -- Sign extend old value
prog_rom: rom4096x32
-- Instantiate a Block ROM
PORT MAP (clk
=> clk,
-- System clock
reset => reset, -- Asynchronous reset
pma
=> pc(18 TO 29),-- Program memory address 12 bits
pmd
=> pmd);
-- Program memory data
ir <= pmd;
dma <= rA + imm32 WHEN I
ELSE rA + rB;
store <= st AND (dma <= DRAMAX4); -- DRAM store



ELSE C <= '0';
END IF;
END IF;
-- Compute and store new register values
IF imm THEN -- Set flag: last was imm instruction
rI <= imm16; LI <= true;
ELSE
rI <= (OTHERS => '0'); LI <= false;
END IF;
IF D>0 THEN -- Do not write r(0)
IF link THEN -- Store LR for operation branch with link aka call
r(D) <= pc_d; -- Old pc + 1 op after return
ELSE
r(D) <= res(1 TO 32); -- Store ALU result
END IF;
END IF;
IF write THEN out_port <= rD(24 TO 31); END IF;--LSBs are right
END IF;
END PROCESS ALU;
--
--
--
--
--
--
--
--
--
--
-- Extra test pins:
pc_OUT <= pc(20 TO 31);
ir_imm16 <= imm16;
op_code <= op; -- Data processing ops
jc_OUT <= '1' WHEN jc ELSE '0'; -- Xilinx modified
i_OUT <= '1' WHEN I ELSE '0'; -- Xilinx modified
me_ena <= mem_ena; -- Control signals
r1_OUT <= r(1);
-- First two user registers
r2_OUT <= r(2); r3_OUT <= r(3);
-- Next two user registers
r15_OUT <= r(15); r19_OUT <= r(19);
-- Compiler registers
END fpga;