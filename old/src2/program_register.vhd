library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_register is
    generic (
        AWIDTH : integer := 256;
        WIDTH : integer := 32
    );
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        address : in std_logic_vector(WIDTH-1 downto 0);
        value : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture arch_program_register of program_register is

type RAM is array (AWIDTH-1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
signal program_register : RAM;

begin
    
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            value <= (others=>'0');
        elsif rising_edge(clk) then
            if en = '1' then
                value <= program_register(to_integer(unsigned(address)));
            elsif en = '0' then
                value <= (others=>'0');
            end if;
        end if;
    end process;
end architecture;