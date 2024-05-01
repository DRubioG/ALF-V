library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mem_controller is
    Port ( 
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        rs1, rs2 : in std_logic_vector(4 downto 0);
        val1, val2 : in std_logic_vector(4 downto 0);
        val1_out, val2_out : out std_logic_vector(31 downto 0)
    );
end mem_controller;

architecture arch_mem_controller of mem_controller is

type registers is array (0 to 31) of std_logic_vector(31 downto 0);
signal regis : registers;

begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            val1_out <= (others=>'0');
        elsif rising_edge(clk) then
            if en = '1' then
                val1_out <= regis(val1);
            elsif en = '0' then
                val1_out <= (others=>'0');
            end if;
        end if;
    end process;
    
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            val2_out <= (others=>'0');
        elsif rising_edge(clk) then
            if en = '1' then
                val2_out <= regis(to_integer(val2));
            elsif en = '0' then
                val2_out <= (others=>'0');
            end if;
        end if;
    end process;


end arch_mem_controller;
