LIBRARY ieee ;
USE ieee.std logic 1164.all ;
ENTITY mux21 IS
PORT (wl, wO, s : IN STD_LOGIC ;
fl : OUT STD_LOGIC )
END mux21 ;
ARCHITECTURE Behavior OF mux21 IS
BEGIN
WITH s SELECT
f 1 <= wO WHEN '0 ' ,
Wl WHEN OTHERS /
END Behavior ;
LIBRARY ieee ;
USE ieee.std logic 1164.all ;
ENTITY fulladd IS
PORT (Cin, x, y : IN STD_LOGIC ;
S, Cout : OUT STD LOGIC ) ;

END fulladd ;
ARCHITECTURE LogicFunc OF fulladd IS
BEGIN
s <= x XOR y XOR Cin ;
Cout <= (x AND y) OR (Cin AND x) OR (Cin AND y) ;
END LogicFunc ;
LIBRARY ieee;
USE ieee.stdlogic 1164.all ;
ENTITY Four bitadder IS
PORT (Cin
x3, x2, xl, xO
y3, y2, yl, yO
s3, s2, si, sO
Cout _
END Four bitadder ;
ARCHITECTURE Structure OF Four bitadder IS
SIGNAL cl, c2, c3 :STD_LOGIC ;
COMPONENT fulladd
PORT (
IN
IN
IN
OUT
OUT
STD_
STD_
STD_
STD_
STD
LOGIC ;
LOGIC ;
_LOGIC ;
LOGIC ;
LOGIC )
Cin, x, y
s, Cout
IN STD_LOGIC ;
OUT STD LOGIC )
END COMPONENT
BEGIN
stageO: fulladdPORT MAP ( Cin, xO, yO, sO, cl ) ;
stagel: fulladdPORT MAP ( cl, xl, yl, si, c2 ) ;
stage2: fulladdPORT MAP ( c2, x2, y2, s2, c3 ) ;
stage3: fulladdPORT MAP ( c3, x3, y3, s3, Cout );
—Cin => Cout, x=>x3, y=>y3, s=>s3;
END structure;
—Arithmetic Unit design
LIBRARY IEEE; USE
IEEE.STD LOGIC 1164.ALL;
ENTITY Arithmetic Unit IS
PORT ( X3, X2, Xl, XO
Y3, Y2, Yl, YO
SO
Cout
f3, f2, fl, fO:
end Arithmetic Unit;
ARCHITECTURE Structure OF Arithmetic Unit IS
IN STD_LOGIC;
IN STD_LOGIC;
IN STD_LOGIC;
OUT STD_LOGIC;
BUFFER STD LOGIC);
COMPONENT Mux21
PORT ( wl, wO, s
fl
END COMPONENT;
COMPONENT Four bitadder
PORT ( Cin
x3, x2.
y3, y2.
IN
OUT
xl.
yi.
STD LOGIC;
STD_LOGIC;
: IN
xO : IN
yO : IN
r
) ;
STD_LOGIC;
STD_LOGIC;
STD_LOGIC;



s3, s2,
Cout
c2, cl,
62, dl.
si, sO
OUT STD_LOGIC;
OUT STD LOGIC ) ;
cO
dO
:std_logic;
:std logic;
BEGIN
d3
d2
dl
dO
Mux 3
Mux2
Muxl
MuxO
Adder
<= ( not Y3);
<= ( not Y2);
<= ( not Yl);
<= ( not YO);
MuX21 PORT MAP
Mux21 PORT MAP
Mux21 PORT MAP
Mux21 PORT MAP
(
Four bitAdder PORT MAP
d3, Y3,
62, Y2,
dl, Yl,
dO, YO,
T MAP (
SO
SO
SO
SO
SO,
, c3) ;
, c2);
, cl) ;
, cO) ;
X3, X2,
XI
end Structure;
— 4-bit Two-Function Logic unit design
LIBRARY IEEE;
USE IEEE.STD LOGIC 1164.ALL;
ENTITY Logic Function IS
X3, X2, XI, XO
YO
c0,f3, f2, fl.
PORT (
Y3, Y2,
SO
Yl,
gO
std_logic;
std_logic;
std_logic ;
buffer std_logic ) ;
in
in
in
g3, g2, gl,
end Logic Function ;
ARCHITECTURE Structure OF Logic Function IS
COMPONENT Mux21
PORT( wl, wO, s
fl
END COMPONENT;
signal m3, m2, ml,
signal n3, n2, nl.
begin
mO
nO
: IN STD_LOGIC
: OUT STD_LOGIC
: std_logic;
:std _logic;
m3 <=
m2 <=
ml <=
mO <=
n3 <=
n2 <=
nl <=
nO <=
(X3and Y3)
(X2and Y2)
(XI and Yl)
(XOand YO)
(X3xor Y3)
(X2xor Y2)
(Xlxor Yl)
(XOxor YO)
Mux21 Port map
Port map
Port map
Port map
Mux21
Mux21
Mux21
Mux3:
Mux2:
Muxl:
MuxO:
End Structure
—ALU Design
LIBRARY IEEE;
USE IEEE.STD LOGIC 1164.ALL;
ENTITY ALU IS
PORT ( X3, X2, XI, XO
( n3,
( n2,
( nl,
( nO,
m3,
m2,
ml,
mO,
SO,
SO,
SO,
SO,
g3);
g2);
gl);
gO);
in std logic




in
in
in
out
std_
std_
std_
std_
logic;
logic;
logic
logic
Y3, Y2, Yl, YO : in std logic;
SI, SO : in std_Togic ;
Cout : out std_logic ;
Z3, Z2, Zl, ZO : buffer std_logic );
end ALU;
ARCHITECTURE Structure OF ALU IS
COMPONENT Arithmetic Unit
PORT ( X3, X2, XI, XO
Y3, Y2, Yl, YO
SO
Cout
f3, f2, fl, fO : buffer std_ logic );
END COMPONENT;
COMPONENT Logic Function
PORT ( X3, X2, XI, XO : in std_ logic;
Y3, Y2, Yl, YO : in std_ logic;
SO : in std_ logic ;
g3, g2, gl, gO : buffer std_ logic );
END COMPONENT;
COMPONENT Mux21
PORT ( wl, wO, s : IN STD_LOGIC ;
f1 : OUT STD_LOGIC );
END COMPONENT;
signal m3, m2, ml, mO : std_logic;
signal n3, n2, nl, nO : std_logic;
BEGIN
Arith: Arithmetic Unit Port map
( X3, X2, XI, XO, Y3, Y2, Yl, YO, SO, Cout, m3, m2, ml, mO );
Logic: Logic Function Port map
( X3, X2, XI, XO, Y3, Y2, Yl, YO, SO, n3, n2, nl, nO ) ;
Selection3: Mux21 Port map (n3, m3, SI, Z3);
Selection2: Mux21 Port map (n2, m2, SI, Z2);
Selectionl: Mux21 Port map (nl, ml, SI, Zl) ;
SelectionO: Mux21 Port map (nO, mO, SI, ZO) ;
end Structure;