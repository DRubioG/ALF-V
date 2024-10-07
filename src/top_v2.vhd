library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_v2 is
    Port ( 
        clk : in std_logic;
        rst_n : in std_logic
        
    );
end entity;

architecture Behavioral of top_v2 is

component program_memory is
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        address : in std_logic_vector(7 downto 0);
        instruction : out std_logic_vector(7 downto 0)
    );
end component;

begin


program_memory_inst : program_memory
    port map(
        clk => clk,
        rst_n => rst_n,
        en => '1',
        address => ,
        instruction => 
    );

end Behavioral;
