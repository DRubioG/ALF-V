—VHDL code for Microprogrammed CPU
—General Purpose Register
-- General purpose register
library ieee;
use ieee.std_logic_1164.all;
entity reg is
generic ( n : integer := 8); — Port declarations
port ( elk, load : in std_logic;— elk: clock, load: load data to reg
x : in std_logic_vector ((n-l) downto 0); — x: input
d : out std_logic_vector ((n-l) downto 0) ); — d: output
end reg;
architecture reg_arch of reg is
begin — Process when clock and load change
pi : process ( elk, load ) — if the clocking signal (elk)
begin — represents the rising edge
if elk = '1' and elk'event then — and if load pin is high then
if load = '1' then — stores the data into
d <= x; — the reg
end if;
end if;
end process;
end reg_arch;
—Program Counter ( PC )
— program counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
entity pctr is
generic ( n : integer := 8 ); — Port declarations
port ( elk, clr, inc, load : in std_logic; — elk: clock, clr: clear PC
x : in std_logic_vector ((n-l) downto 0);— inc: PC <- PC+1
d : out std_logic_yector ((n-l) downto 0) ); —,load: load
—branch address, x: input
— d: output
end pctr;
architecture pctr_arch of pctr is
signal in_d : unsigned (x1range); — in_d: connect d
signal in_x : unsigned (x'range); — in_x: connect x
begin
pi : process ( elk, clr, inc, load ) — if elk = rising edge
begin — and clr = 1
if elk = '1' and elk'event then — then PC <- 0
if clr = '1' then — if elk = rising edge
in_d <= conv_unsigned(0,n);— and clr=0,ine = 1, load = 0
else — then PC <- PC + 1
if inc = '1' then — if elk = rising edge
in_d <= in_d +1; — and clr= 0, inc = 0, load = 1
else — then PC <- x
if load = '1' then
in_d <= in_x;
end if;
end if;
end if;
end if;
end process;
gl : for i in x'range generate — for i = 0 to 7 loop
in_x(i) <= x(i);
d(i) <= in_d(i);
end generate;
end pctr_arch;
—Full adder
— Full adder
library ieee;
use ieee.std_logic_1164.all;
entity fal is -- Port declarations
port ( a, b, c : in std_logic; — c: carry input
s, cout, anda, nota : out std_logic );— s: sum, cout: carry output
end fal; — anda: a AND b, nota: NOT a
architecture fal_arch of fal is
signal in_anda : std_logic; — in_anda: connect anda
begin
s <= a xor b xor c;
cout <= in_anda or (b and c) or (c and a);
in_anda <= a and b;
nota <= not a;
anda <= in_anda;
end fal_arch;
—ALU module
— Arithmetic logic unit
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
entity alu is — Port declarations
generic ( n : integer := 8 );
port (CTRL : in STD_LOGIC_VECTOR (0 to 2); — CTRL: control input
L, R : in STD_LOGIC_VECTOR ( (n-1) downto 0);— L, R: source inputs
F : out STD_LOGIC_VECTOR ((n-1) downto 0);-- F: result output
C, Z : out STD_LOGIC ); — C: carry flag, Z: zero flag
end alu;
architecture alu_arch of alu is
component fal
port ( a, b, c : in STD_LOGIC;
s, cout, anda, nota : out STD_LOGIC );
end component;
signal in_L, in_R, in_xR, in_F : unsigned (L'range);
— in_L: connect L, a, in_R: connect R
signal in_zer, in_sum, in_and, — in_xR: connect b, in_F: connect F
in_not, in_inc, in_dec : unsigned (L'range); — in_zer: connect 0,
— in_sum: connect s
signal in_c : STD_LOGIC_VECTOR (n downto 0);
— in_and: connect anda, in_zf: connect Z
signal in_zf : boolean;— in_not: connect nota,
begin — in_c: connect C, CTRL(2), cout
gen : for i in L'range generate — for i = 0 to 7 loop
fa_i : fal port map ( in_L(i), in_xR(i), in_c(i), in_sum(i),
in_c(i+1), in_and(i), in_not(i) );
in_xR(i) <= in_R(i) xor CTRL(2); — CTRL(2) can determine add
— CTRL(2) = 0
in_R(i)<= R(i); — or subtract CTRL(2) = 1
in_L(i)<= L(i); — if CTRL(2) = 1, in_R(i) xor CTRL(2)
F(i) <= in_F(i) after 200 ps;— performs l's complement of R
end generate;
in_zer <= CONV_UNSIGNED(0, n);
in_inc <= in_L + 1 after 500 ps;
in_dec <= in_L - 1 after 500 ps;
in_c(0) <= CTRL(2); — performs 2's complement of R
C <= in_c(n);
in_zf <= ( in_F = 0 ) after 500 ps;


with CTRL select
in_F <= in_zer when "000",
in_R when "001",
in_sum when "010",
in_sum when "Oil",
in_inc when "100",
in_dec when "101", -
in_and when "110", -
in_not when others; --
with in_zf select
z <= '1' when True,
'0' when others;
end alu_arch;
—ROM
— Read only memory (ROM)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY cpu_rom IS
PORT ( addr : in std_logic_vector
data : out std_logic_vector
end cpu_rom;
ARCHITECTURE Arch_rom OF cpu_rom IS
— Define instruction to opcode
f=0 if ctrl=0
f=R if ctrl=l
f=L+R if ctrl=2
f=L-R if ctrl=3
f=L+l if ctrl=4
f=L-l if ctrl=5
f=LSR if ctrl=6
f=~L if ctrl=others
z = 1 if in_zf = true
z= 0 if in zf = others
constant LDA
constant STA
constant ADD
constant SUB
constant JZ
constant JC
constant A_ND
constant CMA
constant INCA
constant DCRA
constant HLT
constant OUTPR
constant Dl
constant D2
constant D3
constant D4
constant D5
constant PROD
constant CNTR
constant V2
constant V3
constant V4
constant V5
constant V6
constant V7
constant V8
constant V9
constant VA
constant VB
constant VC
constant VD
constant VE
(6 downto 0);—
(7 downto 0)) ;■
addr: address input
- data: data output
- Programming ROM
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
Define label to memory address
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic_vector
std_logic vector
"00001000"
"00001001"
"00001010"
"00001011"
"00001100"
"00001101"
"00001110"
"00000000"
"00000010"
"00000100"
"00000110"
"10010000"
"00000110"
"00000111"
"00001000"
"00001001"
"00001010"
"10000000"
"10000001"
"10000010"
"10000011"
"10000100"
"10000101"
"10000110"
"10000111"
"10001000"
"10001001"
"10001010"
"10001011"
"10001100"
"10001101"
"10001110"
•— 08h
•—09h
• — OAh
•— OBh
OCh
•—ODh
•—OEh
•—OOh
— 02h
•— 04h
— 06h
•--90h
•—06h
•—07h
•—08h
•—09h
--OAh
•—80h
—81h
--82h
•--83h
--84h
— 85h
--86h
— 87h
— 88h
— 89h
— 8Ah
•—8Bh
•—8Ch
—8Dh
• —8Eh



ENDS when "0110111"
STA when "0111000"
CNTR when "0111001"
LDA when "0111010"
Dl when "0111011"
SUB when "0111100"
Dl when "0111101"
JZ when "0111110"
LOP when "0111111"
LDA when "1000000"
PROD when "1000001"
STA when "1000010"
OUTPR when "1000011"
when others;
37 Goto End, ENDS
38 CNTA <- A
39
3A Goto Loop
3B Dl = 80h
3C A <- A - Dl (A
3D Dl = 80h
3E If A = 0 then
3F
4 0 End: Outport <-
41
42 Outport <- A
43
n
OOh)
PROD
HLT
data <= in_data after 200 ps;
end Arch_rom;
—RAM
— Random access memory (RAM)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
entity cpu_ram is
generic ( nw : integer := 8;
nl : integer := 4 );
port ( rw, en : in STD_LOGIC/— rw: read/write, en: enable RAM
addr : in STD_LOGIC_VECTOR ((nl-1) downto 0);
— addr: address input
d_in : in STD_LOGIC_VECTOR ((nw-1) downto 0);
data input
out STD LOGIC VECTOR ((nw-1) downto 0)
d in:
d out
);■
- d_out data
output
end cpu_ram/
architecture cpu_ram_arch of cpu_ram is
type Ram_Word is array ( d_in'range ) of STD_LOGIC;— type declaration
type Ram_Array is array ( 0 to ((2**nl)-l)) of Ram_Word;— type declaration
signal in__din, doutl, dout2, in_dout
signal in_addr
in_out: connect d_out
signal Ram_Mem
Ram_Word;— in_din: connect d_in,
—dout2: connect 0
: unsigned (addr'range);
Ram_Array;-
in_addr: connect
-addr
begin
p: process ( rw, en, in_addr )
variable intaddr : integer;
begin
intaddr := CONV_INTEGER (in_addr)
doutl <= Ram_Mem(intaddr);
if en - '0' and rw = '0' then
if en = 0 and rw = 0
Ram_Mem(intaddr) <= in_din after 500 ps;
then write data into the RAM
end if;
end process/
with en select
in_dout <= doutl when '0',
dout2 when others;
convert




gl: for i in d_out'range generate
— for i = 0 to 7 loop
in_din(i) <= d_in(i);
d_out(i) <= in_dout(i) after 200 ps;
dout2(i) <= '0';
— set dout2 := "00000000"
end generate;
g2: for i in addr'range generate
— for i = 0 to 3 loop
in_addr(i) <= addr(i) after 100 ps;
end generate;
end cpu_ram_arch;
—Memory for CPU ( ROM + RAM)
— memory for cpu
library IEEE;
use IEEE.std_logic_1164.all;
entity memory is
port ( RW, EN : in STD_LOGIC;
— RW: read/write, EN: enable memory
addr, din : in STD_LOGIC_VECTOR
-- addr: address input, din: data input
dout : out STD_LOGIC_VECTOR
— dout: data output
ioout : out STD_LOGIC_VECTOR
— ioout: data io output
end memory;
architecture memory_arch of memory is
component cpu_ram
generic ( nw, nl : integer );
port ( rw, en : in STD_LOGIC;
addr : in STD_LOGIC_VECTOR ((nl-1) downto 0);
d_in : in STD_LOGIC_VECTOR ((nw-1) downto 0);
d_out : out STD_LOGIC_VECTOR ((nw-1) downto 0) );
end component;
component cpu_rom
port ( addr : in STD_LOGIC_VECTOR (6 downto 0);
data : out STD_LOGIC_VECTOR (7 downto 0) );
end component; — in_dl: connect data
signal in_dl, in_d2 : STD_LOGIC_VECTOR ( 7 downto 0);
— in_d2: connect d_out
signal in_EnRAM : STD_LOGlC;
— in_EnRAM: connect en
begin
roml : cpu_rom port map (addr=>addr(6 downto 0), data =>in_dl)/
rami : cpu_ram generic map (8, 4)
port map (rw=>RW, en=>in_EnRAM, addr=>addr(3 downto 0),
d_in=>din, d_out=>in_d2);
in_EnRAM <= EN or ( not addr(7) ) or addr(6) or addr(5) or addr(4);
-- memory mapping:
with addr(7) select
— programmed ROM when address =
dout <= in_d2 when '1',
— 00000000 to 01111111 (128 bytes)
in_dl when others;
— RAM when address =




with addr select
— 10000000 to 10001111 (16 bytes)
ioout <= din after
— 10 when address =
"00000000"
— 10010000 (1 byte)
end memory_arch;
—Multiplexer 2 to 1
— Multiplexer 2 to 1
library IEEE;
use IEEE.std_logic_1164.all;
entity mux2tol is
generic ( n : integer :=8);
port ( si, sO : in STD_LOGIC_VECTOR ((n-1) downto 0);
-- sO, si: source inputs
s : in STD_LOGIC;
— s: select line
f : out STD_LOGIC_VECTOR ((n-1) downto 0) );
— f: output
end mux2tol;
architecture arch_mux of mux2tol is
begin
with s select
f <= sO when '0',
si when others;
end arch_mux;
—Instruction Decoder
— Instruction decoder
library IEEE;
use IEEE.std_logic_1164.all;
entity ir_to_xc is
port ( i : in STD_LOGIC_VECTOR (1 downto 0);
— i: op-code bit 1 & 2
xc : out STD_LOGIC_VECTOR ( 2 downto 0) );
— xc: group number output
end ir_to_xc;
architecture ir_to_xc_arch of ir_to_xc is
begin
with i select
xc <= "001" when "00",
— group 0
"010" when "01",
— group 1
"100" when "10",
— group 2
"000" when others;
— group 3
end ir to xc arch;
—Micro2 module
— Overall hardware2 ( PC + Reg + Mux2tol + ALU + Memory + IR_to_XC )
library ieee;
use ieee.std_logic_1164.all;



entity micro2 is
port ( Ctrl : in STD_LOGIC_VECTOR (0 TO 12);
— Ctrl: control inputs C0-C12
clr, elk : in STD_LOGIC;
— elk: clock, clr: clear
dataout : out STD_LOGIC_VECTOR ( 7 downto 0);
— dataout: data output
z, c, i3, iO : out STD_LOGlC;
— z: zero flag, c: carry flag
xc : out std_logic_vector ( 2 downto 0) )/
— i3, iO: op-code bit 3 & 0
end micro2;
— xc: group number
architecture micro2_arch of micro2 is
component pctr
generic ( n: integer);
port ( elk, clr,
— clr: CO, inc: CI, load: C2
inc, load : in STD_LOGIC;
x : in STD_LOGIC_VECTOR ((n-l) downto 0);
— x: branch
d : out STD_LOGIC_VECTOR ((n-l) downto 0)
— d: memory reference
end component;
component reg -- instantiate Register
generic ( n: integer );
port ( elk, load : in STD_LOGIC;
— load: C4, C7, C8, C9
x : in STD_LOGIC_VECTOR ((n-l) downto 0);
— x: data input
d : out STD_LOGIC_VECTOR ((n-l) downto 0)
— d: data output
end component;
component mux2tol — instantiate mux 2 to 1
generic ( n: integer );
port ( si, sO : in STD_LOGIC_VECTOR ((n-l) downto 0);
— si: from buffer, sO: from PC
s : in STD_LOGIC;
— s: C3
f : out STD_LOGIC_VECTOR ((n-l) downto 0 ) )/
— f: to MAR
end component;
component alu — instantiate ALU
generic ( n: integer );
port ( CTRL : in STD_LOGIC_VECTOR (0 to 2);
— CTRL: C10, Cll, C12
L, R : in STD_LOGIC_VECTOR ((n-l) downto 0);
— L, R: data input
F : out STD_LOGIC_VECTOR ((n-l) downto 0);
— F: data output
C, Z : out STD_LOGIC );
-- C: carry flag, Z: zero flag
end component;
component memory — instantiate memory



port ( RW, EN : in STD_LOGIC;
— RW: C5, EN: C6
addr, din : in STD_LOGIC_VECTOR (7 downto 0);
— addr: from MAR, din: from reg A
dout : out STD_LOGIC_VECTOR (7 downto 0);
— dout: to PC, IR, buffer
ioout : out STD_LOGIC_VECTOR (7 downto 0) );
— ioout: to 10
end component;
component ir_to_xc — instantiate instruction decoder
port ( i : in STD_LOGIC_VECTOR (1 downto 0);
— i: from IR, II & 12
xc : out STD_LOGIC_VECTOR ( 2 downto 0) );
— xc: group number
end component;
signal ope, oir, omux, omar,
— ope: connect PC & MUX
orega, obuf, oalu, omem : STD_LOGIC_VECTOR ( 7 downto 0);
STD_LOGIC VECTOR (0 downto 0);
(L)
map
(R)
(8)
in_clr,
(8)
Buffer
Ctrl (8),
(8)
ctrl(l), ctrl(2), omem, ope);
omem, oir);
omux, omar);
— oir: connect IR & instruction decoding
signal in_clr, en_flag, incf : STD_L0GIC;
— omux: connect MUX & MAR
signal i_cf, o_cf
— omar: connect MAR & memory
begin
— orega: connect Reg A & ALU
the_pc : pctr generic
— obuf: connect Buffer & ALU
port map (elk,
— oalu: connect Reg A & ALU (F)
the_ir : reg generic map
— omem: connect memory & PC, IR,
port map (elk,
— in_clr: connect CO or clr
the_mar : reg generic map
— en_flag: connect Z, C
port map (elk, Ctrl(4),
— inzf: connect ALU
the_rega : reg generic map (8)
— incf: connect ALU
port map (elk, Ctrl(9), oalu, orega);
Z, i_cf: connect C
reg generic map (8)
Z, o_cf: connect C
port map (elk, Ctrl (7), omem, obuf);
mux2tol generic map (8)
port map (obuf, ope, Ctrl(3), omux);
alu generic map (8)
port map (CTRL=>ctrl(10 to 12), L=>orega,
R=>obuf, F=>oalu, C=>incf, Z=>inzf);
-The zero flag is connected directly to the alu, the carry flag is instantiated.
the_cf : reg generic map (1)
port map (elk, en_flag, i_cf, o_cf);
the_mem : memory port map (ctrl(5), Ctrl(6), omar,
orega, omem, dataout);
the dec : ir to xc port map (i=>oir(2 downto 1), xc=>xc);
i_zf: connect
the_buf
o_zf: connect
the_mux
the alu





in_clr <= ctrl(O) or clr;
— Ctrl (0): PC <- 0
c <= o_cf(0);
i_cf(0) <= incf;
i3 <= oir(3);
— i3: type classifier
iO <= oir(0);
-- iO: subcategory within a group
en_flag <= Ctrl(10) or Ctrl(11) or Ctrl(12);
— Ctrl(10), Ctrl(11), Ctrl(12): — ALU control input
end micro2 arch;
—Memory Control Unit ( module CM )
— Control Unit
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY cm IS
PORT ( addr : in std_logic_vector (5 downto 0);
— addr: address input
cmdb : out std_logic_vector (22 downto 0) );
— cmbd: data output
end cm;
ARCHITECTURE Arch_cm OF cm IS
signal in_cmdb : std_logic_vector (22 downto 0);
— in_cmbd: connect cmbd
— Binary microprogram
— The size of the control memory is 53 x 23 bits. The 23-bit control word
—consists of 13- bit control function —containing CO through C12 with CO as bit
--12 and C12 as bit 0. The branch address field is 6-bit wide (bits 13-18). For
—example, consider the code for line 0 with the operation PC <- 0 in the
—following. Since there is no condition in this operation, condition select
—field ( CS ) and branch address field ( Brn ) are all 0's. To clear PC to 0,
—CO = 1 . To disable RAM, C6 = 1 and, C5 (R/W ) is arbitrarily set to one.
begin
with addr select
— 22 19 12 0
ICSI Brn I CTR FUNC |
n_cmdb <= "00000000001000011000000" when
"00000000000000111000000" when "000001
"00000000000100010010000
"00110011100000011000000
"01100010000000011000000
"01010010100000011000000
"01000011000000011000000
"10001101000000011000000
"00000000000000011001111
"10000000010000011000000
"00000000000000011001100
"10000000010000011000000
"00000000000000011001101
"10000000010000011000000
"01100101110000011000000
when
when
when
when
when
when
when
when
'000010"
'000011"
'000100"
•000101"
'000110"
'000111"
'001000"
'001001"
when "001010"
when "001011"
"001100"
'001101"
'001110"
when
when
when
'01011000000000011000000" when "001111"
'01001010010000011000000" when "010000"
'00000000000000111000000" when "010001"
'000000",— 0 PC <- 0
—1 FETCH MAR<-PC
—2 IR<- M(MAR), PC <- PC +1
— 3 IF 13=1, goto MEMR(14)
— 4 IF XC0=1, goto CMA(8)
— 5 IF XC1=1, goto INCA(10)
— 6 IF XC2=1, goto DCRA(12)
— 7 goto HALT(50)
— 8 CMA A <- ~A
— 9 goto FETCH
— 10 INCA A <- A + 1
— 11 goto FETCH
— 12 DCRA A <- A - 1
— 13 goto FETCH
— 14 MEMREF IF XC0=1,
LDSTO(23)
— 15 IF XC1=1, goto ADSUB(32)
— 16 IF XC2=1, goto JMPS(41)
— 17 AND MAR <- PC
goto



'00000000000100010100000" when "010010'
'00000000000001111000000"
'00000000000000010100000"
'00000000000000011001110"
'10000000010000011000000"
'00000000000000111000000'
'00000000000100010100000'
when "010011"
when "010100"
when "010101"
when "010110"
when "010111"
when "011000"
"00000
"OHIO
"00000
"00000
"10000
"00000
"10000
"00000
"00000
00000
11110
00000
00000
00001
00000
00001
00000
00000
00011
00000
00000
00000
00000
00000
00000
00001
01000
11000000"
11000000"
10100000"
11001001"
11000000"
00000000"
11000000"
11000000"
10100000"
when
when
when
when
when
when
when
when
when
'011001"
'011010"
'011011"
'011100"
'011101"
'011110"
'011111"
'100000"
'100001"
when "100010'
when "100011'
when "100100'
when "100101'
when "100110'
when
when
when
when
when
"00000000000001111000000
"00000000000000010100000
"01111001110000011000000
"00000000000000011001010
"10000000010000011000000
"00000000000000011001011
"10000000010000011000000
"00000000000000111000000
"00000000000000011000000
"01111011110000011000000
"00011100100000011000000
"00000000000100011000000
"10000000010000011000000
"00101100100000011000000
"00000000000100011000000
"10000000010000011000000
"00000000000010010000000
"10000000010000011000000
"10001101000000011000000
cmdb <= in_cmdb after 200 ps;
end Arch_cm;
—Microprogram Counter Module(MPC)
— Microprogramming counter
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
entity cntr is
generic ( n : integer := 6 );
port( elk : in STD_LOGIC; — elk
in STD LOGIC;— clr:
'100111"
'101000"
'101001"
when "101010"
when "101011"
when "101100"
when "101101"
when "101110"
'101111"
■110000"
when "110001"
when "110010"
when "110011"
when others;
-- 18 BUFFER <- M(MAR),
PC <- PC+1
-- 19 MAR <- BUFFER
-- 20 BUFFER <- M(MAR)
-- 21 A <- A A BUFFER
— 22 goto FETCH
-- 23 LDSTO MAR <- PC
24 BUFFER <- M(MAR),
PC <- PC + 1
25 MAR <- BUFFER
26 IF 10=1, goto STO(30)
27 LOAD BUFFER <- M(MAR)
28 A <- BUFFER
29 goto FETCH
30 STO M(MAR) <- A
31 goto FETCH
32 ADSUB MAR <- PC
33 BUFFER <- M(MAR),
PC <- PC +1
34 MAR <- BUFFER
35 BUFFER <- M(MAR)
36 IF 10=1, goto SUB(39)
37 ADD A <- A + BUFFER
38 goto FETCH
39 SUB A <- A - BUFFER
4 0 goto FETCH
41 JMPS MAR <- PC
42
43 IF 10=1, goto JOC(47)
44 JOZ IF Z=l, goto LOADPC
45 PC <- PC + 1
4 6 goto FETCH
47 JOC IF C=l, goto LOADPC(50)
4 8 PC <- PC+ 1
4 9 goto FETCH
50 LOADPC PC <- M(MAR)
51 goto FETCH
52 HALT goto HALT
in STD_LOGIC;— li
in STD_LOGIC_VECTOR
out STD LOGIC VECTOR
clr
li
x
d
end cntr;
architecture cntr_arch of cntr is
signal in_d : UNSIGNED (x'range);
signal in_x : UNSIGNED (x'range);
: clock
clear MPC
load/increase
((n-l) downto 0);■
((n-l) downto 0)
in_d: connect d
in x: connect x
x: data input
>—d:data




begin
pi : process ( elk, clr, li)
begin
if elk = '1' and elk'event then — if elk = rising edge
if clr = '1' then — and clr = 1
in_d <= CONV_UNSIGNED(0, n) after 200 ps; — then MPC <- 0
else — if elk = rising edge
if li = '0' then — and clr =0, li = 0
in_d <= in_d + 1 after 500 ps/-- MPC <- MPC + 1
else — if elk = rising edge
in_d <= in_x after 500 ps;— and clr =0, li = 1
end if; — MPC <- x
end if;
end if;
end process;
gl : for i in x'range generate — for i = 0 to 5 loop
in_x(i) <= x(i);
d(i) <= in_d(i);
end generate;
end cntr_arch;
—Mux 9 to 1
— Multiplexer 9 to 1
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY mux9tol IS
PORT ( w : in std_logic_vector (8 downto 0);— w: input
s : in std_logic_vector (3 downto 0);— s: select line
f : out std_logic ); — f: output
end mux9tol;
ARCHITECTURE Arch_Mux OF mux9tol IS
begin
with s select
f <= w(0) when "0000",
w(l) when "0001",
w(2) when "0010",
w(3) when "0011",
w(4) when "0100",
w(5) when "0101",
w(6) when "0110",
w(7) when "0111",
w(8) when others;
end Arch Mux;




--Microl ( MPC + decoder + CM )
— Overall hardware! ( MPC + Mux9tol + CM )
library IEEE;
use IEEE.std_logic_1164.all;
entity microl is
port( Z : in STD_LOGIC; — Z: zero flag
C : in STD_LOGIC; — C: carry flag
13 : in STD_LOGIC; — 13: type classifier( if 13=1, then
XC : in STD_LOGIC_VECTOR (2 downto 0);— it is a MRL, othewise
—it is a NMRI)
10 : in STD_LOGIC; — XC: group number
CLR : in STD_LOGIC; — 10: subcategory within a group
CLK : in STD_LOGIC; — CLR: clear MPC
CTN : out STD_LOGIC_VECTOR (0 to 12) );— CLK: clock
end microl; — CTN: control functions
architecture microl_arch of microl is
component cntr
generic ( n : integer );
port ( elk : in STD_LOGIC;
in STD_LOGIC;
in stdjlogic;
in STD_LOGIC_VECTOR ((n-1) downto 0);
out STD_LOGIC_VECTOR ((n-1) downto 0) );
end component;
component mux9tol
port ( w : in std_logic_vector (8 downto 0);
s : in std_logic_vector (3 downto 0);
f : out std_logic );
end component;
component cm
port ( addr : in std_logic_vector (5 downto 0);
cmdb : out std_logic_vector (22 downto 0) );
end component;
signal in_addr, in_brnh : STD_LOGIC_VECTOR (5 downto 0);
— in_addr: connect MPC & CM
signal in_cs : STD_LOGIC_VECTOR (3 downto 0);
— in_brnh: connect MPC cmbd(18 downto 13)
signal in_li, IH, IL : STD_LOGIC;
— in_cs: connect s & cmbd(22 downto 19)
begin — in_li: connect MUX & MPC
cntrl : cntr generic map (6) — IH: connect Vcc, IL: connect GND
port map (clk=>clk, clr=>clr, li=>in_li, x=>in_brnh,
d=>in_addr);
mux91 : mux9tol port map (w(8)=>IH, w(7)=>10, w(6)=>XC(0),
n
elk
clr
li
x
d
cml
IH <=
IL <=
w(5)=>XC(l), w(4)=>XC(2), w(3)=>13,
w(2)=>C, w(l)=>Z, w(0)=>IL, s=>in_cs, f=>in_li);
cm port map (addr=>in_addr, cmdb(22 downto 19)=>in_cs,
cmdb(18 downto 13)=>in_brnh, cmdb(12 downto
0)=>CTN);
■1';
'0';
end microl arch;





—CPU module
— Microprogrammed CPU
library IEEE;
use IEEE.std_logic_1164.all;
entity CPU is
port ( elk, reset: in STD_LOGIC;— elk: clock
d_out: out STD_LOGIC_VECTOR (7 downto 0)
end CPU;
architecture CPU_arch of CPU is
component microl
in STD_LOGIC;
in STD_LOGIC;
in STD_LOGIC;
in STD_LOGIC_VECTOR (2 downto 0);
in STD_LOGIC;
in STD_LOGIC;
in STD_LOGIC;
out STD LOGIC VECTOR (0 to 12) );
);- d_out:data output
port (
Z
C
13
XC
10
CLR
CLK
CTN
end component;
component micro2
port (
Ctrl
clr, elk
dataout
Z, C, 13,10
XC
end component;
signal in_Z, in_C, in_I3, in_I0 :
-- in_Z: connect Z, in_C: connect C
— in 13: connect 13, in 10: connect 10
in STD_LOGIC_VECTOR (0 to 12);
in STD_LOGIC;
out STD_LOGIC_VECTOR (7 downto 0);
out STD_LOGIC;
out STD LOGIC VECTOR (2 downto 0));
STD LOGIC;
signal Ctrl
signal in_XC
— Ctrl: connect CTN, in_xc: XC
begin
the_mpc : microl port map (
the_hdw : micro2 port map (
end CPU arch;
STD_LOGIC_VECTOR (0 to 12);
STD LOGIC VECTOR (2 downto 0);
in_Z, in_C, in_I3, in_XC, in_I0,
reset, elk, Ctrl );
Ctrl, reset, elk, d_out, in_Z, in_C,
in 13, in 10, in XC );
—Test Bench for CPU module
— CPU test bench
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY testbench IS
END testbench;
ARCHITECTURE behavior OF testbench IS — Architecture of the test bench
COMPONENT cpu — instantiate CPU module
PORT ( elk : IN std_logic;
reset : IN std_logic;
d_out : OUT std_logic_vector (7 downto 0) );
END COMPONENT;
SIGNAL elk : std_logic;
SIGNAL reset : std_logic;




SIGNAL d_out : std_logic_vector (7 downto 0);
BEGIN
uut : cpu PORT MAP( elk => elk, — port map CPU module
reset => reset,
d_out => d_out );
— Shortest period : 2001 ps = Highest frequency ; 500 MHz
clk_process : PROCESS — Process for Clock generator
BEGIN
for i in 0 to 600 loop — generate clock with period of 2ns
CLK <= '0';
wait for 1001 ps/
CLK <= '1•;
wait for 1000 ps;
end loop/
wait;
END PROCESS;
rst_test : PROCESS — Process for Test stimulus
BEGIN
reset <= '1';— reset goes high for 3.5 ns then goes low
wait for 3500 ps;
reset <= '0';
wait;
END PROCESS;