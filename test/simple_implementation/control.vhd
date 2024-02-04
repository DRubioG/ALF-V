library ieee;
use ieee.std_logic_1164.all;

entity control is
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        inst : in  std_logic_vector(6 downto 0);
        branch : out std_logic;
        memread : out std_logic;
        memtoreg : out std_logic;
        aluop : out std_logic;
        memwrite : out std_logic;
        alusrc : out std_logic;
        regwrite : out std_logic
    );
end entity;

architecture arch_control of control is

begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then

        elsif rising_edge(clk) then
            case inst is
                when "" => 
                when "" => 
                when "" => 
                when "" => 
                when "" => 
                when "" => 
            end case;
        end if;
    end process;

end architecture;