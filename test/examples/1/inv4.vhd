library ieee;
use ieee.std_logic-1164.all;
entity inv4 is
generic(size:positive);
port(a:in std_logic_vector(size-1 downto 0);
b:out std_logic_vector(size-1 downto 0));
end inv4;
architecture inv4_example of inv4 is
component inv
port(x:in std_logic;
y:out std_logic)/
end component;
—VHDL code for inv
library IEEE;
useIEEE.std_logic_1164.all;
entity inv is
port (x: in BIT; y: out BIT);
end inv;
architecture LOGIC1 of inv is
begin
y<=not x;
end LOGIC1;
begin
fl: for n in size-1 downto 0 generate
f2: inv port map(a(n),b(n));
end generate;
end inv4_example;
library ieee;
use ieee.std_logic_1164.all;
entity inv8_16 is
port(al:in std_logic_vector(7 downto 0);
bl:out std_logic vector(7 downto 0);

a2:in std_logic_vector(15 downto 0);
b2:out std_logic_vector(15 downto 0));
end inv8_16;
architecture inv_diffsize of inv8_16 is
component inv4
generic(size:positive)/
port(a:in std_logic_vector(size-1 downto 0)/
b:out std_logic-vector(size-1 downto 0))/
end component;
begin
gl:inv4 generic map(size=>8) port map(al,bl);
g2:inv4 generic map (size=>16) port map(a2,b2);
end invjdiffsize/