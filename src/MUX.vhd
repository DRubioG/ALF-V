library ieee;
use ieee.std_logic_1164.all;

entity MUX is
    generic (
        WIDTH : integer := 32
    );
    port (
        A, B : in std_logic_vector(WIDTH-1 downto 0);
        selection : in std_logic;
        Y : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture arch_MUX of MUX is

begin

     Y <= A when selection = '0' else
          B when selection = '1';
    
end architecture;