library ieee;
use ieee.std_logic_1164.all;

entity ALU is
    generic(
        WIDTH : integer := 32
    );
    port(
        srcA : in std_logic_vector(WIDTH-1 downto 0);
        srcB : in std_logic_vector(WIDTH-1 downto 0);
        
        zero : out std_logic;
        ALUResult : out std_logic_vector(WIDTH-1 downto 0)
    );  
end entity;

architecture arch_ALU of ALU is

begin

end architecture;