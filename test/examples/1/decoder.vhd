library ieee;
use ieee.std_logic_1164.all;
entity 4tol6dec is
port (x:in std_logic_vector (3 downto 0);
e:in std_logic;
d: out std_logic_vector (0 to 15) ) ;
end 4tol6dec;
architecture decoder of 4tol6dec is
component 2to4dec
port (x:in std_logic_vector (1 downto 0);
e:in std_logic;
d: out std_logic_vector (0 to 3);
end component;
signal k: std_logic_vector (0 to 3)) ;
begin
fl: for i in 0 to 3 generate
dec_l: 2to4dec port map(x(l downto 0), k(i), d(4*i to 4*i+3));
f2: if i=3 generate
dec_2: 2to4dec port map (x(i downto i-1), e, k);
end generate;
end decoder;