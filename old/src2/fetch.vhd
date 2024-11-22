library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        inst : in std_logic_vector(31 downto 0);
        inst_out : out std_logic_vector(31 downto 0);
        address_input : in std_logic_vector(31 downto 0);
        address_output : out std_logic_vector(31 downto 0);
        pc : in std_logic_vector(31 downto 0)
    );
end entity;

architecture arch_fetch of fetch is
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            address_output <= (others=>'0');
        elsif rising_edge(clk) then
            if en = '1' then
                address_output <= std_logic_vector(unsigned(address_input)+unsigned(pc));
            elsif en = '0' then
                address_output <= (others=>'0');
            end if;
        end if;
    end process;
    
    inst_out <= inst;

end architecture;