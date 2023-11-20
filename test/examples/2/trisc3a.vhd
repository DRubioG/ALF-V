-- ===================================================================
-- Title: T-RISC 3 address machine
-- Description: This is the top control path/FSM of the
-- T-RISC, with a single 3 phase clock cycle design
-- It has a 3-address type instruction word
-- implementing a subset of the ARMv7 Cortex A9 architecture
-- ===================================================================
LIBRARY ieee; USE ieee.std_logic_1164.ALL;
PACKAGE n_bit_type IS
-- User defined types
SUBTYPE U8 IS INTEGER RANGE 0 TO 255;
SUBTYPE U12 IS INTEGER RANGE 0 TO 4095;
SUBTYPE SLVA IS STD_LOGIC_VECTOR(11 DOWNTO 0); -- Address prog. mem.
SUBTYPE SLVD IS STD_LOGIC_VECTOR(31 DOWNTO 0); -- Width data
SUBTYPE SLVD1 IS STD_LOGIC_VECTOR(32 DOWNTO 0); -- Width data + 1
SUBTYPE SLVP IS STD_LOGIC_VECTOR(31 DOWNTO 0); -- Width instruction
SUBTYPE SLV4 IS STD_LOGIC_VECTOR(3 DOWNTO 0); -- Full opcode size
END n_bit_type;
LIBRARY work;
USE work.n_bit_type.ALL;
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_unsigned.ALL;
-- ===================================================================
ENTITY trisc3a IS
PORT(clk
: IN STD_LOGIC; -- System clock
reset
: IN STD_LOGIC; -- Active low asynchronous reset
in_port : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input port
out_port : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- Output port
-- The following test ports are used for simulation only and should be
-- comments during synthesis to avoid outnumbering the board pins
--
r0_OUT
: OUT SLVD; -- Register 0
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
sp_OUT
: OUT SLVD; -- Register 13 aka stack pointer
--
lr_OUT
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
: OUT STD_LOGIC_VECTOR(11 DOWNTO 0); -- Program counter
--
ir_imm12 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0); -- Immediate value
--
imm32_out : OUT SLVD;
-- Sign extend immediate value
--
op_code : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
-- Operation code
);
END;



-- ===================================================================
ARCHITECTURE fpga OF trisc3a IS
-- Define GENERIC to CONSTANT for _tb
CONSTANT WA : INTEGER := 11; -- Address bit width -1
CONSTANT NR : INTEGER := 15; -- Number of Registers -1; PC is extra
CONSTANT WD : INTEGER := 31;
-- Data bit width -1
CONSTANT DRAMAX : INTEGER := 4095; -- No. of DRAM words -1
CONSTANT DRAMAX4 : INTEGER := 1073741823; -- X"3FFFFFFF";
-- True DDR RAM bytes -1
COMPONENT dpram4Kx32 IS
PORT (clk_a : IN STD_LOGIC; -- System clock DRAM
clk_b : IN STD_LOGIC; -- System clock PROM
addr_a : IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- Data mem. address
addr_b : IN STD_LOGIC_VECTOR(11 DOWNTO 0);-- Prog. mem. address
data_a : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data in for DRAM
we_a : IN STD_LOGIC := '0'; -- Write only DRAM
q_a
: OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- DRAM output
q_b
: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- ROM output
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
SIGNAL
SIGNAL
SIGNAL
SIGNAL
SIGNAL
op : SLV4;
dmd, pmd, dma : SLVD;
cond : STD_LOGIC_VECTOR(3 DOWNTO 0);
ir, tpc, pc, pc4_d, pc4, pc8, branch_target : SLVP;-- PCs
mem_ena, not_clk : STD_LOGIC;
jc, go, dp, rlsl : boolean; -- jump and decoder flags
I, set, P, U, bx, W, L : boolean;-- Decoder flags
movt, movw, str, ldr, branch, bl : boolean; -- Special instr.
load, store, read, write, pop, push : boolean; -- I/O flags
popPC, popA1, pushA1, popA2, pushA2: boolean;--LDR/STM instr.
ind, ind_d : INTEGER RANGE 0 TO NR; --push/pop index
N, Z, C, V : boolean; -- CPSR flags
D, NN, M : INTEGER RANGE 0 TO 15; -- Register index
Rd, Rdd, Rn, Rm, r_M : SLVD := (OTHERS => '0');-- current Ops
Rd1, Rn1, Rm1 : SLVD1; -- Sign extended Ops
imm4 : STD_LOGIC_VECTOR(3 DOWNTO 0); -- imm12 extended
imm5 : STD_LOGIC_VECTOR(4 DOWNTO 0); -- Within Op2
imm12 : STD_LOGIC_VECTOR(11 DOWNTO 0); -- 12 LSBs
sxt12 : STD_LOGIC_VECTOR(19 DOWNTO 0); -- Total 32 bits
imm24 : STD_LOGIC_VECTOR(23 DOWNTO 0); -- 24 LSBs
sxt24 : STD_LOGIC_VECTOR(5 DOWNTO 0); -- Total 30 bits
bimm32, imm32, mimm32 : SLVD; -- 32 bit branch/mem/ALU
imm33 : SLVD1; -- Sign extended ALU constant
-- OP Code of instructions:
-- The 4 bit for all data processing instructions
CONSTANT opand : SLV4 := "0000"; -- X0
CONSTANT eor
: SLV4 := "0001"; -- X1
CONSTANT sub
: SLV4 := "0010"; -- X2
CONSTANT rsb
: SLV4 := "0011"; -- X3
CONSTANT add
: SLV4 := "0100"; -- X4
CONSTANT adc
: SLV4 := "0101"; -- X5





CONSTANT
CONSTANT
CONSTANT
CONSTANT
CONSTANT
CONSTANT
CONSTANT
CONSTANT
CONSTANT
CONSTANT
sbc
rsc
tst
teq
cmp
cmn
orr
mov
bic
mvn
:
:
:
:
:
:
:
:
:
:
SLV4
SLV4
SLV4
SLV4
SLV4
SLV4
SLV4
SLV4
SLV4
SLV4
:=
:=
:=
:=
:=
:=
:=
:=
:=
:=
"0110";
"0111";
"1000";
"1001";
"1010";
"1011";
"1100";
"1101";
"1110";
"1111";
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
X6
X7
X8
X9
XA
XB
XC
XD
XE
XF
-- Register array definition 16x32
TYPE REG_ARRAY IS ARRAY(0 TO NR) OF SLVD;
SIGNAL r : REG_ARRAY;
BEGIN
WITH ir(31 DOWNTO 28) SELECT -- Evaluation of condition bits
go <= Z WHEN "0000", NOT Z WHEN "0001", -- Zero: EQ or NE
C WHEN "0010", NOT C WHEN "0011", -- Carry: CS or CC
N WHEN "0100", NOT N WHEN "0101", -- Negative: MI or PL
V WHEN "0110", NOT V WHEN "0111", -- Overflow: Vs or VC
C AND NOT Z WHEN "1000",
-- HI
NOT C AND Z WHEN "1001",
-- LS
N=V WHEN "1010", N/=V WHEN "1011", -- GE or LT
NOT Z AND N=V WHEN "1100",
-- GT
Z AND N/=V WHEN "1101",
-- LE
true WHEN OTHERS;
-- Always
P1: PROCESS(ir) -- find last '1' for PUSH/POP format A1
BEGIN
ind <= 0;
FOR i IN 0 TO NR LOOP
IF ir(i)='1' THEN ind <= i; END IF;
END LOOP;
END PROCESS;
P2: PROCESS (reset, clk) -- FSM of processor
BEGIN -- update the PC
IF reset = '0' THEN
tpc <= (OTHERS => '0');pc4_d <= (OTHERS => '0');
popPC <= false;
ELSIF falling_edge(clk) THEN
IF jc THEN
tpc <= branch_target ; -- any jumps that use immediate
ELSE
tpc <= pc4; -- Usual increment by 4 bytes
END IF;
pc4_d <= pc4;
popPC <= false;
IF (popA1 AND ind=15) OR (popA2 AND D=15) THEN
popPC <= true; -- Last op= pop PC ?




END IF;
END IF;
END PROCESS P2;
-- true PC in dmd register if last op is pop AND ind=15
pc <= dmd WHEN popPC ELSE tpc;
pc4 <= pc + X"00000004"; -- Default PC increment is 4 bytes
pc8 <= pc + X"00000008"; -- 2 OP PC increment is 8 bytes
jc <= go AND (branch OR bl OR bx OR (pop AND ind=15)); -- New PC?
sxt24 <= (OTHERS => imm24(23)); -- Sign extend the constant
bimm32 <= sxt24 & imm24 & "00"; -- Immediate for branch
branch_target <= r_m WHEN bx ELSE
bimm32 + pc8; -- Jump are PC relative
-- Mapping of the instruction, i.e., decode instruction
op
<= ir(24 DOWNTO 21);
-- Data processing OP code
imm4 <= ir(19 DOWNTO 16);
-- imm12 extended
imm5 <= ir(11 DOWNTO 7);
-- The shift values of Op2
imm12 <= ir(11 DOWNTO 0);
-- Immediate ALU operand
imm24 <= ir(23 DOWNTO 0);
-- Jump address
-- P, B, W Decoder flags not used
set <= true WHEN ir(20)='1' ELSE false; -- update flags for S=1
I <= true WHEN ir(25)='1' ELSE false;
L <= true WHEN ir(20)='1' ELSE false; -- L=1 load L=0 store
U <= true WHEN ir(23)='1' ELSE false; -- U=1 add offset
movt <= true WHEN ir(27 DOWNTO 20)= "00110100" ELSE false;
movw <= true WHEN ir(27 DOWNTO 20)= "00110000" ELSE false;
branch <= true WHEN ir(27 DOWNTO 24)= "1010" ELSE false;
bl <= true WHEN ir(27 DOWNTO 24)= "1011" ELSE false;
bx <= true WHEN ir(27 DOWNTO 20)= "00010010" ELSE false;
ldr <= true WHEN ir(27 DOWNTO 26)= "01" AND L ELSE false; -- load
str <= true WHEN ir(27 DOWNTO 26)= "01" AND NOT L ELSE false;--store
popA1 <= true WHEN ir(27 DOWNTO 16)= "100010111101" ELSE false;
popA2 <= true WHEN ir(27 DOWNTO 16)= "010010011101" ELSE false;
pop <= popA1 OR popA2;
-- load multiple (A1) or one (A2) update sp-4 after memory access
pushA1 <= true WHEN ir(27 DOWNTO 16)= "100100101101" ELSE false;
pushA2 <= true WHEN ir(27 DOWNTO 16)= "010100101101" ELSE false;
push <= pushA1 OR pushA2;
-- store multiple (A1) or one (A2) update sp+4 before memory access
dp <= true WHEN ir(27 DOWNTO 26)= "00" ELSE false;-- data processing
NN <= CONV_INTEGER('0' & ir(19 DOWNTO 16)); -- Index 1. source reg.
M <= CONV_INTEGER('0' & ir(3 DOWNTO 0));-- Index 2. source register
D <= CONV_INTEGER('0' & ir(15 DOWNTO 12));-- Index destination reg.
Rn <= r(NN); -- First operand ALU
Rn1 <= Rn(31) & Rn; -- Sign extend 1. operand by one bit
r_M <= r(M);
rlsl <= true WHEN ir(6 DOWNTO 4)= "000" ELSE false;--Shift left reg.
Rm <= imm32 WHEN I -- 2. ALU operand maybe constant or register
ELSE r_M(30 DOWNTO 0)& "0" WHEN imm5="00001" AND rlsl --LSL=1
ELSE r_M(29 DOWNTO 0)& "00" WHEN imm5="00010" AND rlsl --LSL=2
ELSE r_M; -- Second operand ALU



Rm1 <= Rm(31) & Rm; -- Sign extend 2. operand by one bit
Rd <= r(D); -- Old destination register value
Rd1 <= Rd(31) & Rd; -- Sign extend old value by one bit
mimm32 <= sxt12 & imm12; -- memory immediate
dma <= Rn + Rm WHEN I
ELSE r(13) - 4 WHEN push -- same as STMDB sp!, {Rx}
ELSE r(13) WHEN pop -- same as LDMIA sp!, {Rx}
ELSE Rn + mimm32 WHEN U AND NN/=15
ELSE Rn - mimm32 WHEN NOT U AND NN/=15
ELSE pc8 + mimm32 WHEN U and NN=15 -- PC-relative is special
ELSE pc8 - mimm32;
store <= (str OR push) AND (dma <= DRAMAX4); -- DRAM store
load <= (ldr OR pop) AND (dma <= DRAMAX4); -- DRAM load
write <= str AND (dma > DRAMAX4); -- I/O write
read <= ldr AND (dma > DRAMAX4); -- I/O read
mem_ena <= '1' WHEN store ELSE '0'; -- Active for store only
Rdd <= r(ind) WHEN pushA1 ELSE Rd;
not_clk <= NOT clk;
-- ARM PC-relative ops require True Dual Port RAM with dual clock
mem: dpram4Kx32 -- Instantiate a Block DRAM and ROM
PORT MAP(clk_a => not_clk, -- System clock DRAM
clk_b => clk, -- System clock PROM
addr_a => dma(13 DOWNTO 2),-- Data memory address 12 bits
addr_b => pc(13 DOWNTO 2),-- Program memory address 12 bits
data_a => Rdd, -- Data in for DRAM
we_a
=> mem_ena, -- Write only DRAM
q_a
=> dmd, -- Data RAM output
q_b
=> pmd); -- Program memory data
ir <= pmd;
-- ALU imm computations:
sxt12 <= (OTHERS => imm12(11)); -- Sign extend the constant
imm32 <= imm4 & imm12 & Rd(15 DOWNTO 0) WHEN movt ELSE
X"0000" & imm4 & imm12 WHEN movw ELSE
sxt12 & imm12; -- Place imm16 in MSBs for movt
imm33 <= imm32(31) & imm32; -- sign extend constant
ALU: PROCESS (op,Rm1,Rn1,in_port,dmd,reset,clk,load,read,
C,Rd1,dp,movw,imm33,movt,pop)
VARIABLE res: STD_LOGIC_VECTOR(32 DOWNTO 0);
VARIABLE Cin: STD_LOGIC;
BEGIN
IF C THEN Cin := '1'; ELSE Cin := '0'; END IF;
res := Rd1; -- Keep old/default
IF DP THEN
CASE op IS
WHEN opand => res := Rn1 AND Rm1;
WHEN eor | teq => res := Rn1 XOR Rm1;
WHEN sub => res := Rn1 - Rm1;
WHEN rsb => res := Rm1 - Rn1;





WHEN
WHEN
WHEN
WHEN
WHEN
add | cmn => res := Rn1 + Rm1;
adc => res := Rn1 + Rm1 + Cin;
sbc => res := Rn1 - Rm1 + Cin -1;
rsc => res := Rm1 - Rn1 + Cin -1;
tst => IF movw THEN res := imm33; ELSE
res := Rn1 AND Rm1; END IF;
WHEN cmp => IF movt THEN res := imm33; ELSE
res := Rn1 - Rm1; END IF;
WHEN orr => res := Rn1 OR Rm1;
WHEN mov => res := Rm1;
WHEN bic => res := Rn1 AND NOT Rm1;
WHEN mvn => res := NOT Rm1;
WHEN OTHERS => res := Rd1;
END CASE;
END IF;
IF load OR pop THEN res := '0' & dmd; END IF;
IF read THEN res := "0" & X"000000" & in_port; END IF;
-- Update flags and registers --------------------------------
IF reset = '0' THEN
-- Asynchronous clear
Z <= false; C <= false; N <= false; V <= false;
out_port <= (OTHERS => '0');
FOR k IN 0 TO NR LOOP -- reset to zero
r(k) <= conv_std_logic_vector(k,32); --X"00000000";
END LOOP;
ELSIF rising_edge(clk) THEN -- ARMv7 has 4 flags
IF dp AND set THEN -- set flags N and Z for all 16 OPs
IF res(31) = '1' THEN N <= true; ELSE N <= false; END IF;
IF res(31 DOWNTO 0) = X"00000000" THEN
Z <= true; ELSE Z <=false; END IF;
IF res(32) = '1' AND op /= mov THEN
C <= true; ELSE C <=false; END IF;
-- Compute new C flag except of MOV
IF res(32) /= res(31) AND (op = sub OR op = rsb OR op = add
OR op = adc OR op = sbc OR op = rsc OR op = cmp OR op = cmn)
THEN -- Compute new overflow flag for arith. ops
V <= true; ELSE V <=false; END IF;
END IF;
IF bl THEN -- Store LR for operation branch with link aka call
r(14) <= pc4_d; -- Old pc + 1 op after return
ELSIF push THEN
r(13) <= r(13) - 4;
ELSIF read OR load OR movw OR movt OR (dp AND
op /= tst AND op /= teq AND op /= cmp AND op /= cmn) THEN
r(D) <= res(31 DOWNTO 0);--Store ALU result (not for test ops)
IF popA1 AND ind /= 13 THEN
r(13) <= r(13) + 4;
r(ind) <= res(31 DOWNTO 0);
END IF;
IF popA2 AND D /= 13 THEN
r(D) <= res(31 DOWNTO 0);
r(13) <= r(13) + 4;
END IF;




END IF;
IF write THEN out_port <= Rd(7 DOWNTO 0); END IF;
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
--
-- Extra test pins:
pc_OUT <= pc(11 DOWNTO 0);
ir_imm12 <= imm12;
imm32_out <= imm32;
op_code <= op; -- Data processing ops
jc_OUT <= '1' WHEN jc ELSE '0'; -- Xilinx modified
i_OUT <= '1' WHEN I ELSE '0'; -- Xilinx modified
me_ena <= mem_ena; -- Control signals
r0_OUT <= r(0); r1_OUT <= r(1);
-- First two user registers
r2_OUT <= r(2); r3_OUT <= r(3);
-- Next two user registers
sp_OUT <= r(13); lr_OUT <= r(14);
-- Compiler registers
END fpga;