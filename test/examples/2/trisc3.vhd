-- Title: T-RISC 3 address machine
-- ==================================================================
-- Title: T-RISC 3 address machine
-- Description: This is the top control path/FSM of the
-- T-RISC, with a single 3 phase clock cycle design
-- It has a 3-address type instruction word
-- implementing a subset of the Nios II architecture
-- ==================================================================
LIBRARY ieee; USE ieee.std_logic_1164.ALL;
PACKAGE n_bit_type IS
-- User defined
SUBTYPE U8 IS INTEGER RANGE 0 TO 255;
SUBTYPE U12 IS INTEGER RANGE 0 TO 4095;
SUBTYPE SLVA IS STD_LOGIC_VECTOR(11 DOWNTO 0); --
SUBTYPE SLVD IS STD_LOGIC_VECTOR(31 DOWNTO 0); --
SUBTYPE SLVP IS STD_LOGIC_VECTOR(31 DOWNTO 0); --
SUBTYPE SLV6 IS STD_LOGIC_VECTOR(5 DOWNTO 0); --
END n_bit_type;
types
Address prog. mem.
Width data
Width instruction
Full opcode size
LIBRARY work;
USE work.n_bit_type.ALL;
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_unsigned.ALL;
-- ===================================================================
ENTITY trisc3n IS
PORT(clk
: IN STD_LOGIC; -- System clock
reset
: IN STD_LOGIC; -- Active low asynchronous reset
in_port : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input port
out_port : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Output port
-- The following test ports are used for simulation only and should be
-- comments during synthesis to avoid outnumbering the board pins
r1_OUT
: OUT SLVD; -- Register 1
r2_OUT
: OUT SLVD; -- Register 2
r3_OUT
: OUT SLVD; -- Register 3
r4_OUT
: OUT SLVD; -- Register 4
sp_OUT
: OUT SLVD; -- Register 27 aka stack pointer
ra_OUT
: OUT SLVD; -- Register 31 aka return address
jc_OUT
: OUT STD_LOGIC;
-- Jump condition flag
me_ena
: OUT STD_LOGIC;
-- Memory enable
k_OUT
: OUT STD_LOGIC;
-- constant flag
pc_OUT
: OUT STD_LOGIC_VECTOR(11 DOWNTO 0); -- Program counter
ir_imm16 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Immediate value
imm32_out : OUT SLVD;
-- Sign extend immediate value
op_code : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
-- Operation code
);
END;
-- ===================================================================
ARCHITECTURE fpga OF trisc3n IS
-- Define GENERIC to CONSTANT for _tb
CONSTANT WA : INTEGER := 11; -- Address bit width -1
CONSTANT NR : INTEGER := 31;
-- Number of Registers -1
CONSTANT WD : INTEGER := 31;
-- Data bit width -1
CONSTANT DRAMAX : INTEGER := 4095; -- No. of DRAM words -1


CONSTANT DRAMAX4 : INTEGER := 16383; -- No. of DRAM bytes -1
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
op, opx : SLV6;
dmd, pmd, dma : SLVD;
imm5 : STD_LOGIC_VECTOR(4 DOWNTO 0);
sxti, imm16 : STD_LOGIC_VECTOR(15 DOWNTO 0);
imm26 : STD_LOGIC_VECTOR(25 DOWNTO 0);
imm32 : SLVD;
A, B, C : INTEGER RANGE 0 TO NR;
rA, rB, rC : SLVD := (OTHERS => '0');
ir, pc, pc4, pc8, branch_target, pcimm26 : SLVP;-- PCs
eq, ne, mem_ena, not_clk : STD_LOGIC;
jc, kflag : boolean; -- jump and imm flags
load, store, read, write : boolean; -- I/O flags
-- OP Code of instructions:
-- The 6 LSBs IW for all implemented operations sorted by op code
CONSTANT call
: SLV6 := "000000"; -- X00
CONSTANT jmpi
: SLV6 := "000001"; -- X01
CONSTANT addi
: SLV6 := "000100"; -- X04
CONSTANT br
: SLV6 := "000110"; -- X06
CONSTANT andi
: SLV6 := "001100"; -- X0C
CONSTANT ori
: SLV6 := "010100"; -- X14
CONSTANT stw
: SLV6 := "010101"; -- X15
CONSTANT ldw
: SLV6 := "010111"; -- X17
CONSTANT xori
: SLV6 := "011100"; -- X1C
CONSTANT bne
: SLV6 := "011110"; -- X1E
CONSTANT beq
: SLV6 := "100110"; -- X26
CONSTANT orhi
: SLV6 := "110100"; -- X34
CONSTANT stwio
: SLV6 := "110101"; -- X35
CONSTANT ldwio
: SLV6 := "110111"; -- X37
CONSTANT R_type : SLV6 := "111010"; -- X3A
-- 6 bits for OP eXtented instruction with OP=3A=111010
CONSTANT ret
: SLV6 := "000101"; -- X05
CONSTANT jmp
: SLV6 := "001101"; -- X0D
CONSTANT opand : SLV6 := "001110"; -- X0E
CONSTANT opor
: SLV6 := "010110"; -- X16
CONSTANT opxor : SLV6 := "011110"; -- X1E
CONSTANT add
: SLV6 := "110001"; -- X31
CONSTANT sub
: SLV6 := "111001"; -- X39
-- Data RAM memory definition use one BRAM: DRAMAXx32
TYPE MTYPE IS ARRAY(0 TO DRAMAX) OF SLVD;
SIGNAL dram : MTYPE;
-- Register array definition 32x32
TYPE REG_ARRAY IS ARRAY(0 TO NR) OF SLVD;
SIGNAL r : REG_ARRAY;


BEGIN
P1: PROCESS (op, reset, clk) -- FSM of processor
BEGIN -- update the PC
IF reset = '0' THEN
pc <= (OTHERS => '0'); pc8 <= (OTHERS => '0');
ELSIF falling_edge(clk) THEN
IF jc THEN
pc <= branch_target ; -- any jumps that use immediate
ELSE
pc <= pc4; -- Usual increment by 4 bytes
pc8 <= pc + X"00000008";
END IF;
END IF;
END PROCESS p1;
pc4 <= pc + X"00000004"; -- Default PC increment is 4 bytes
pcimm26 <= pc(31 DOWNTO 28) & imm26 & "00";
jc <= (op=beq AND rA=rB) OR (op=R_type AND (opx=ret OR opx=jmp))
OR (op=bne AND rA/=rB) OR (op=jmpi) OR (op=br) OR (op=call);
branch_target <= pcimm26 WHEN (op=jmpi OR op=call)
ELSE r(31) WHEN (op=R_type AND opx=ret)
ELSE rA WHEN (op=R_type AND opx=jmp)
ELSE imm32+pc4; -- WHEN (op=beq OR op=bne OR op=br)
-- Mapping of the instruction, i.e., decode instruction
op <= ir(5 DOWNTO 0);
-- Operation code
opx <= ir(16 DOWNTO 11);
-- OPX code for ALU ops
imm5 <= ir(10 DOWNTO 6);
-- OPX constant
imm16 <= ir(21 DOWNTO 6);
-- Immediate ALU operand
imm26 <= ir(31 DOWNTO 6);
-- Jump address
A <= CONV_INTEGER('0' & ir(31 DOWNTO 27)); -- Index 1. source reg.
B <= CONV_INTEGER('0' & ir(26 DOWNTO 22));
-- Index 2. source/des. register
C <= CONV_INTEGER('0' & ir(21 DOWNTO 17));-- Index destination reg.
rA <= r(A); -- First source ALU
rB <= imm32 WHEN kflag ELSE r(B); -- Second source ALU
rC <= r(C); -- Old destination register value
-- Immediate flag 0= use register 1= use HI/LO extended imm16;
kflag <= (op=addi) OR (op=andi) OR (op=ori) OR (op=xori)
OR (op=orhi) OR (op=ldw) OR (op=ldwio);
sxti <= (OTHERS => imm16(15)); -- Sign extend the constant
imm32 <= imm16 & X"0000" WHEN op=orhi
ELSE sxti & imm16; -- Place imm16 in MSbs for ..hi
prog_rom: rom4096x32
-- Instantiate a Block RAM
PORT MAP (clk
=> clk,
-- System clock
reset => reset, -- Asynchronous reset
pma
=> pc(13 DOWNTO 2),-- Program memory address 12 bits
pmd
=> pmd);
-- Program memory data
ir <= pmd;
dma <= rA + imm32;
store <= ((op=stw) OR (op=stwio)) AND (dma <= DRAMAX4);-- DRAM store
load <= ((op=ldw) OR (op=ldwio)) AND (dma <= DRAMAX4); -- DRAM load


write <= ((op=stw) OR (op=stwio)) AND (dma > DRAMAX4); -- I/O write
read <= ((op=ldw) OR (op=ldwio)) AND (dma > DRAMAX4); -- I/O read
mem_ena <= '1' WHEN store ELSE '0'; -- Active for store only
not_clk <= NOT clk;
ram: PROCESS (reset, dma, not_clk) -- Use one BRAM: 4096x32
VARIABLE idma : U12 := 0;
BEGIN
idma := CONV_INTEGER('0' & dma(13 DOWNTO 2));-- uns/skip 2 LSBs
IF reset = '0' THEN
-- Asynchronous clear
dmd <= (OTHERS => '0');
ELSIF rising_edge(not_clk) THEN
IF mem_ena = '1' THEN
dram(idma) <= rB; -- Write to RAM at falling clk edge
END IF;
dmd <= dram(idma); -- Read from RAM at falling clk edge
END IF;
END PROCESS;
ALU: PROCESS (op,opx,rA,rB,rC,in_port,dmd,reset,clk,load,read)
VARIABLE res: SLVD;
BEGIN
res := rC; -- keep old/default
IF (op=R_type AND opx=add) OR (op=addi) THEN res:=rA + rB; END IF;
IF op=R_type AND opx=sub THEN res := rA - rB; END IF;
IF (op=R_type AND opx=opand) OR (op=andi) THEN res := rA AND rB;
END IF;
IF (op=R_type AND opx=opor) OR (op=ori) OR (op=orhi) THEN
res := rA OR rB; END IF;
IF (op=R_type AND opx=opxor) OR (op=xori) THEN res := rA XOR rB;
END IF;
IF load THEN res := dmd; END IF;
IF read THEN res := X"000000" & in_port; END IF;
IF reset = '0' THEN
-- Asynchronous clear
out_port <= (OTHERS => '0');
FOR k IN 0 TO NR LOOP -- Need to reset at least r(0)
r(k) <= X"00000000";
END LOOP;
ELSIF rising_edge(clk) THEN -- Nios has no zero or carry flags !
IF op=call THEN -- Store ra for operation call
r(31) <= pc8; -- Old pc + 1 op after return
ELSIF kflag AND B>0 THEN -- All I-type
r(B) <= res;
ELSIF C > 0 THEN
r(C) <= res; -- Store ALU result (default)
END IF;
IF write THEN out_port <= rB(7 DOWNTO 0); END IF;
END IF;
END PROCESS ALU;
-- Extra test pins:
pc_OUT <= pc(11 DOWNTO 0);
ir_imm16 <= imm16;
imm32_out <= imm32;
op_code <= op; -- Program
--jc_OUT <= jc; -- Control signals
jc_OUT <= '1' WHEN jc ELSE '0'; -- Xilinx modified


k_OUT <= '1' WHEN kflag ELSE '0'; -- Xilinx modified
me_ena <= mem_ena; -- Control signals
r1_OUT <= r(1); r2_OUT <= r(2);
-- First two user registers
r3_OUT <= r(3); r4_OUT <= r(4);
-- Next two user registers
sp_OUT <= r(27); ra_OUT <= r(31);
-- Compiler registers
END fpga;