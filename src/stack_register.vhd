library ieee;
use ieee.std_logic_1164.all;

entity stack_register is
    generic (
        WIDTH_REGISTER : integer := 5;
        WIDTH_ADDRESS : integer := 32
    );
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        regist : in std_logic_vector(WIDTH_REGISTER-1 downto 0);
        regist_data : out std_logic_vector(WIDTH_ADDRESS-1 downto 0)
    );
end entity;

architecture arch_register of stack_register is
begin
    process (clk, rst_n, regist)
    begin
        if rst = '0' then
            regist_data = (others=>'0');
        elsif rising_edge(clk) then
            if en = '1' then
                case regist is
                    when x"00" =>
                        regist_data <= (others=>'0');
                    when x"01" =>
                    when x"02" =>
                    when x"03" =>
                    when x"04" =>
                    when x"05" =>
                    when x"06" =>
                    when x"07" =>
                    when x"08" =>
                    when x"09" =>
                    when x"0A" =>
                    when x"0B" =>
                    when x"0C" =>
                    when x"0D" =>
                    when x"0E" =>
                    when x"0F" =>
                    when x"10" =>
                    when x"11" =>
                    when x"12" =>
                    when x"13" =>
                    when x"14" =>
                    when x"15" =>
                    when x"16" =>
                    when x"17" =>
                    when x"18" =>
                    when x"19" =>
                    when x"1A" =>
                    when x"1B" =>
                    when x"1C" =>
                    when x"1D" =>
                    when x"1E" =>
                    when x"1F" =>
                    when others => null;
                end case;
            elsif en = '0' then 
                regist_data <= (others=>'0');
            end if;
        end if;
    end process;
end architecture;