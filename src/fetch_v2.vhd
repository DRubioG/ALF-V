library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fetch_v2 is
    Port ( 
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        instruction_in : in std_logic_vector(31 downto 0);
        
    );
end fetch_v2;

architecture arch_fetch_v2 of fetch_v2 is


begin


end architecture;
