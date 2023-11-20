-- Title: T-RISC 2 address machine
-- Description: This is the top control path/FSM of the
-- T-RISC, with a single 3 phase clock cycle design
-- It has a two-address type instruction word
-- implementing a subset of the KCPSM6 aka PicoBlaze v6 architecture
-- =================================================================
-- Xilinx modifications:
-- Use only STD_LOGIC or SLV and no generic in I/O
-- Modify code for jc_out (Boolean)
-- No conversion to/from integer using CONV_INTEGER(id)
-- or CONV_STD_LOGIC_VECTOR(id, width) required
-- =================================================================
LIBRARY ieee; USE ieee.std_logic_1164.ALL;
PACKAGE n_bit_type IS
-- User defined types
SUBTYPE U8 IS INTEGER RANGE 0 TO 255;
SUBTYPE SLVA IS STD_LOGIC_VECTOR(11 DOWNTO 0); -- address prog. mem.
SUBTYPE SLVD IS STD_LOGIC_VECTOR(7 DOWNTO 0); -- width data
SUBTYPE SLVD1 IS STD_LOGIC_VECTOR(8 DOWNTO 0); -- width data + 1 bit
SUBTYPE SLVP IS STD_LOGIC_VECTOR(17 DOWNTO 0); -- width instruction
SUBTYPE SLV6 IS STD_LOGIC_VECTOR(5 DOWNTO 0); -- full opcode size
SUBTYPE SLV5 IS STD_LOGIC_VECTOR(4 DOWNTO 0); -- reduced opcode size
END n_bit_type;
LIBRARY work;
USE work.n_bit_type.ALL;
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_unsigned.ALL;
-- =================================================================
ENTITY trisc2 IS
PORT(clk
: IN STD_LOGIC; -- System clock
reset
: IN STD_LOGIC; -- Active low asynchronous reset
in_port : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input port
out_port : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- Output port
-- The following test ports are used for simulation only and
-- should be comment otherwise not to interfere with pin of the boards
--
s0_OUT
: OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Register 0
--
s1_OUT
: OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Register 1
--
s2_OUT
: OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Register 2
--
s3_OUT
: OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Register 3
--
jc_OUT
: OUT STD_LOGIC;
-- Jump condition flag
--
me_ena
: OUT STD_LOGIC;
-- Memory enable
--
z_OUT
: OUT STD_LOGIC;
-- Zero flag
--
c_OUT
: OUT STD_LOGIC;
-- Carry flag
--
pc_OUT
: OUT STD_LOGIC_VECTOR(11 DOWNTO 0); -- Program counter
--
ir_imm12 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);-- Immediate value
--
op_code : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)); -- Operation code
END;
-- ===================================================================
ARCHITECTURE fpga OF trisc2 IS
-- Define GENERIC to CONSTANT for _tb
CONSTANT WA : INTEGER := 11;
-- Address bit width -1
CONSTANT WR : INTEGER := 3;
-- Register array size width -1


CONSTANT WD : INTEGER := 7;
245
-- Data bit width -1
COMPONENT rom4096x18 IS
PORT (clk
: IN STD_LOGIC;
-- System clock
reset : IN STD_LOGIC;
-- Asynchronous reset
pma
: IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- Program mem.add.
pmd
: OUT STD_LOGIC_VECTOR(17 DOWNTO 0));--Program mem. data
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
op6
: SLV6;
op5
: SLV5;
x, y, imm8, dmd : SLVD;
x0, y0 : SLVD1;
rd, rs : INTEGER RANGE 0 TO 2**(WR+1)-1;
pc, pc1, imm12 : SLVA; -- program counter, 12 bit aaa
pmd, ir
: SLVP;
eq, ne, mem_ena, not_clk : STD_LOGIC;
jc
: boolean;
z, c, kflag : STD_LOGIC; --zero, carry, and imm flags
-- OP Code of instructions:
-- The 5 MSBs for ALU operations (LSB is immidiate flag)
CONSTANT add
: SLV5 := "01000"; -- X10/1
CONSTANT addcy
: SLV5 := "01001"; -- X12/3
CONSTANT sub
: SLV5 := "01100"; -- X18/9
CONSTANT subcy
: SLV5 := "01101"; -- X1A/B
CONSTANT opand
: SLV5 := "00001"; -- X02/3
CONSTANT opor
: SLV5 := "00010"; -- X04/5
CONSTANT opxor
: SLV5 := "00011"; -- X06/7
CONSTANT load
: SLV5 := "00000"; -- X00/1
-- 5 bits for I/O and scratch Pad RAM operations
CONSTANT store
: SLV5 := "10111"; -- X2E/F
CONSTANT fetch
: SLV5 := "00101"; -- X0A/B
CONSTANT opinput : SLV5 := "00100"; -- X08/9
CONSTANT opoutput : SLV5 := "10110"; -- X2C/D
-- 6 Bits for all other operations
CONSTANT jump
: SLV6 := "100010"; -- X22
CONSTANT jumpz
: SLV6 := "110010"; -- X32
CONSTANT jumpnz
: SLV6 := "110110"; -- X36
CONSTANT call
: SLV6 := "100000"; -- X20
CONSTANT opreturn : SLV6 := "100101"; -- X25
-- Scratch Pad memory definition
TYPE MTYPE IS ARRAY(0 TO 255) OF SLVD;
SIGNAL dram : MTYPE;
-- Register array definition
TYPE RTYPE IS ARRAY(0 TO 15) OF SLVD;
SIGNAL s : RTYPE;
-- Link Register stack
TYPE LTYPE IS ARRAY(0 TO 30) OF SLVA;
SIGNAL lreg : LTYPE;
SIGNAL lcount : INTEGER RANGE 0 TO 30;



BEGIN
P1: PROCESS (op6, reset, clk) -- FSM of processor
BEGIN -- store in register ?
IF reset = '0' THEN
pc <= (OTHERS => '0');
lcount <= 0;
ELSIF falling_edge(clk) THEN
IF op6 = call THEN
lreg(lcount) <= pc1; -- store link register
lcount <= lcount +1;
END IF;
IF op6 = opreturn THEN
pc <= lreg(lcount-1); -- Use next address after call/return
lcount <= lcount -1;
ELSIF jc THEN
pc <= imm12; -- any jumps that use 12 bit immediate aaa
ELSE
pc <= pc1; -- Usual increment
END IF;
END IF;
END PROCESS p1;
pc1 <= pc + "000000000001";
jc <= (op6=jumpz AND z='1') OR (op6=jumpnz AND z='0')
OR (op6=jump) OR (op6=call);
-- Mapping of the instruction, i.e., decode instruction
op6 <= ir(17 DOWNTO 12); -- Full Operation code
op5 <= ir(17 DOWNTO 13); -- Reduced Op code for ALU ops
kflag <= ir(12);
-- Immediate flag 0= use reg. 1= use kk;
imm8 <= ir(7 DOWNTO 0);
-- 8 bit immediate operand
imm12 <= ir(11 DOWNTO 0);
-- 12 bit immediate operand
rd <= CONV_INTEGER('0' & ir(11 DOWNTO 8));
-- Index destination/1. source reg.
rs
<= CONV_INTEGER('0' & ir(7 DOWNTO 4)); -- Index 2. source reg.
x <= s(rd); -- first source ALU
x0 <= '0' & x; -- zero extend 1. source
y <= imm8 when kflag='1'
else s(rs); -- second source ALU
y0 <= '0' & y; -- zero extend 2. source
prog_rom: rom4096x18
PORT MAP (clk
=> clk,
reset => reset,
pma
=> pc,
pmd
=> pmd);
ir <= pmd;
--
--
--
--
--
Instantiate a Block RAM
System clock
Asynchronous reset
Program memory address
Program memory data
mem_ena <= '1' WHEN op5 = store ELSE '0'; -- Active for store only
not_clk <= NOT clk;
scratch_pad_ram: PROCESS (reset, not_clk, y0)
VARIABLE idma : U8;
BEGIN
idma := CONV_INTEGER(y0); -- force unsigned
IF reset = '0' THEN
-- Asynchronous clear
dmd <= (OTHERS => '0');



ELSIF rising_edge(not_clk) THEN
IF mem_ena = '1' THEN
dram(idma) <= x; -- Write to RAM at falling clk edge
END IF;
dmd <= dram(idma); -- Read from RAM at falling clk edge
END IF;
END PROCESS;
ALU: PROCESS (op5, op6, x0, y0, c, in_port, dmd, reset, clk)
VARIABLE res: STD_LOGIC_VECTOR(8 DOWNTO 0);
VARIABLE z_new, c_new : STD_LOGIC;
BEGIN
CASE op5 IS
WHEN add
=>
res := x0 + y0;
WHEN addcy =>
res := x0 + y0 + c;
WHEN sub
=>
res := x0 - y0;
WHEN subcy =>
res := x0 - y0 - c;
WHEN opand =>
res := x0 AND y0;
WHEN opor
=>
res := x0 OR y0;
WHEN opxor =>
res := x0 XOR y0;
WHEN load
=>
res := y0;
WHEN fetch =>
res := '0' & dmd;
WHEN opinput => res := '0' & in_port;
WHEN OTHERS =>
res := x0; -- keep old
END CASE;
IF res = 0 THEN z_new := '1'; ELSE z_new := '0'; END IF;
c_new := res(8);
IF reset = '0' THEN
-- Asynchronous clear
z <= '0'; c <= '0';
out_port <= (OTHERS => '0');
ELSIF rising_edge(clk) THEN
CASE op5 IS
-- Compute the new flag values
WHEN addcy | subcy => z <= z AND z_new;
c <= c_new;
-- carry from previous operation
WHEN add | sub =>
z <= z_new; c <= c_new;
-- No carry
WHEN opor | opand | opxor => z <= z_new; c <= '0';
-- No carry; c=0
WHEN OTHERS =>
z <= z; c <= c; -- keep old
END CASE;
s(rd) <= res(7 DOWNTO 0); -- store alu result;
IF op5 = opoutput THEN out_port <= x; END IF;
END IF;
END PROCESS ALU;
--
--
--
--
--
--
--
-- Extra test pins:
pc_OUT <= pc; ir_imm12 <= imm12; op_code <= op6; -- Program
--jc_OUT <= jc; -- Control signals
jc_OUT <= '1' WHEN jc ELSE '0'; -- Xilinx modified
me_ena <= mem_ena; -- Control signals
z_OUT <= z; c_OUT <= c; -- ALU flags
s0_OUT <= s(0); s1_OUT <= s(1);
-- First two register elements
s2_OUT <= s(2); s3_OUT <= s(3);
-- Next two register elements
END fpga;