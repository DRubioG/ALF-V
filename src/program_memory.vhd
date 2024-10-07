library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.program_package.all;

entity program_memory is
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        address : in std_logic_vector(7 downto 0);
        instruction : out std_logic_vector(31 downto 0)
    );
end entity;


architecture arch_program_memory of program_memory is
    
signal instruction_s : std_logic_vector(instruction'length downto 0);
    
begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            instruction_s <= (others=>'0');
        elsif rising_edge(clk) then
            if en = '1' then
                instruction_s <= program_pkg(to_integer(unsigned(address)));
            elsif en = '0' then
                instruction_s <= (others=>'0');
            end if;
        end if;
    end process;


    instruction <= instruction_s;
   

end architecture;