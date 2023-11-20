-- Title: T-RISC 2 address machine
-- Description: This is the top control path/FSM of the
-- T-RISC, with a single 3 phase clock cycle design
-- It has a two-address type ALU instruction type
-- implementing a subset of the KCPSM6 architecture
-- ===================================================================
LIBRARY ieee; USE ieee.std_logic_1164.ALL;
PACKAGE n_bit_int IS
-- User defined types
SUBTYPE U8 IS INTEGER RANGE 0 TO 255;
SUBTYPE SLVA IS STD_LOGIC_VECTOR(11 DOWNTO 0); -- address prog. mem.
SUBTYPE SLVD IS STD_LOGIC_VECTOR(7 DOWNTO 0); -- width data
SUBTYPE SLVD1 IS STD_LOGIC_VECTOR(8 DOWNTO 0); -- width data + 1 bit
SUBTYPE SLVP IS STD_LOGIC_VECTOR(17 DOWNTO 0); -- width instruction
SUBTYPE SLV6 IS STD_LOGIC_VECTOR(5 DOWNTO 0); -- full opcode size
SUBTYPE SLV5 IS STD_LOGIC_VECTOR(4 DOWNTO 0); -- reduced opcode
SUBTYPE SLV4 IS STD_LOGIC_VECTOR(3 DOWNTO 0); -- register array
END n_bit_int;
LIBRARY work;
USE work.n_bit_int.ALL;
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_unsigned.ALL;
-- ===================================================================
ENTITY trisc2 IS
PORT(clk
: IN STD_LOGIC; -- System clock (clk=>CLOCK_50)
reset : IN STD_LOGIC; -- Active low asynchronous reset (KEY(0))
in_port : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Input port (SW)
out_port : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));--Output port (LEDR)
END;
-- ===================================================================
ARCHITECTURE fpga OF trisc2 IS
-- Define GENERIC to CONSTANT for _tb
CONSTANT WA : INTEGER := 11; -- Address bit width -1
CONSTANT WR : INTEGER := 3;
-- Register array size width -1
CONSTANT WD : INTEGER := 7;
-- Data bit width -1
COMPONENT rom4096x18 IS
PORT (clk
: IN STD_LOGIC;
-- System clock
reset : IN STD_LOGIC;
-- Asynchronous reset
pma
: IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- Prog. memory adr.
pmd
: OUT STD_LOGIC_VECTOR(17 DOWNTO 0)); -- Prog. mem. data
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
op6
: SLV6;
op5
: SLV5;
x, y, imm8 : SLVD;
x0, y0 : SLVD1;
rd, rs : INTEGER RANGE 0 TO 2**(WR+1)-1;
pc, pc1, imm12 : SLVA; -- program counter, 12 bit aaa
pmd, ir
: SLVP;
eq, ne, not_clk : STD_LOGIC;
jc
: boolean;



SIGNAL z, c, kflag : STD_LOGIC; -- zero, carry, and imm flags
-- OP Code of instructions:
-- The 5 MSBs for ALU and I/O operations (LSB is imm flag)
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
CONSTANT opxor
: SLV5 := "00011"; -- X06/7
CONSTANT load
: SLV5 := "00000"; -- X00/1
CONSTANT opinput : SLV5 := "00100"; -- X08/9
CONSTANT opoutput : SLV5 := "10110"; -- X2C/D
-- 6 Bits for all other operation
CONSTANT jump
: SLV6 := "100010"; -- X22
CONSTANT jumpz
: SLV6 := "110010"; -- X32
CONSTANT jumpnz
: SLV6 := "110110"; -- X36
-- Register array definition
TYPE RTYPE IS ARRAY(0 TO 15) OF SLVD;
SIGNAL s : RTYPE;
BEGIN
P1: PROCESS (reset, clk) -- FSM of processor
BEGIN
IF reset = '0' THEN
pc <= (OTHERS => '0');
ELSIF falling_edge(clk) THEN
IF jc THEN
pc <= imm12; -- any jumps that use 12 bit immediate aaa
ELSE
pc <= pc1; -- Usual increment
END IF;
END IF;
END PROCESS p1;
pc1 <= pc + X"001";
jc <= (op6=jumpz AND z='1') OR (op6=jumpnz AND z='0') OR (op6=jump);
-- Mapping of the instruction, i.e., decode instruction
op6 <= ir(17 DOWNTO 12); -- Full Operation code
op5 <= ir(17 DOWNTO 13); -- Reduced Op code for ALU ops
kflag <= ir(12);
-- Immediate flag 0= use register 1= use kk;
imm8 <= ir(7 DOWNTO 0);
-- 8 bit immediate operand
imm12 <= ir(11 DOWNTO 0);
-- 12 bit immediate operand
rd <= CONV_INTEGER('0' & ir(11 DOWNTO 8));-- Index dest./1. src reg.
rs
<= CONV_INTEGER('0' & ir(7 DOWNTO 4));-- Index 2. source reg.
x <= s(rd); -- first source ALU
x0 <= '0' & x; -- zero extend 1. source
y <= imm8 when kflag='1'
else s(rs); -- second source ALU
y0 <= '0' & y; -- zero extend 2. source
prog_rom: rom4096x18
PORT MAP (clk
=> clk,
reset => reset,
-- Instantiate a Block RAM
-- System clock
-- Asynchronous reset


