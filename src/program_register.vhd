library ieee;
use ieee.std_logic_1164.all;

entity program_register is
    generic (
        AWIDTH : integer := 256;
        WIDTH : integer := 32
    );
    port (
        clk : in std_logic;
        rst : in std_logic
    );
end entity;

architecture arch_program_register of program_register is

type RAM is array (AWIDTH-1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
signal program_register : RAM;

begin
end architecture;