library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity top_v2_tb is
end top_v2_tb;

architecture Behavioral of top_v2_tb is

component top_v2 is

end component;

signal clk : std_logic := '0';
signal rst_n : std_logic;
signal en : std_logic;

begin

    clk <= not clk after 5ns;
    rst_n <= '0', '1' after 50ns;
    


    

end Behavioral;
