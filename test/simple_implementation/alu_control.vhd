library ieee;
use ieee.std_logic_1164.all;

entity alu_control is
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        aluop : in std_logic;
        inst : in std_logic_vector(3 downto 0);
        alu_mux : out std_logic_vector()
    );
end entity;

architecture arch_alu_control of alu_control is

begin

end architecture;