library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    port (
        clk : in std_logic;
        rst_n: in std_logic;
        
        zero : in std_logic;
        op : in std_logic_vector(6 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        funct7 : in std_logic;
        
        PCWrite : out std_logic;
        AdrSrc : out std_logic;
        MemWrite : out std_logic;
        IRWrite : out std_logic;
        ResultSrc : out std_logic_vector(1 downto 0);
        ALUControl : out std_logic_vector(2 downto 0);
        ALUSrcB : out std_logic_vector(1 downto 0);
        ALUSrcA : out std_logic_vector(1 downto 0);
        ImmSrc : out std_logic_vector(1 downto 0);
        RegWrite : out std_logic
    );
end entity;

architecture arch_control_unit of control_unit is

begin

end architecture;