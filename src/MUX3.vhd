library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX3 is
    generic (
        WIDTH : integer := 32
    );
    Port ( 
        A, B, C : in std_logic_vector(WIDTH-1 downto 0);
        selection : in std_logic_vector(1 downto 0);
        Y : out std_logic_vector(WIDTH-1 downto 0 )
    );
end MUX3;

architecture arch_MUX3 of MUX3 is

begin

    Y <= A when selection = "00" else
         B when selection = "01" else
         C when selection = "10";

end arch_MUX3;
