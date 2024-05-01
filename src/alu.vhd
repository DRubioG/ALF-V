library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.values.all;

entity alu is
    generic (
        WIDTH_DATA : integer := 32;
        DECODE_WIDTH : integer := 3
    );
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        input_A : in std_logic_vector(WIDTH_DATA-1 downto 0);
        input_B : in std_logic_vector(WIDTH_DATA-1 downto 0);
        imm : in std_logic_vector(10 downto 0);
        decode : in std_logic_vector(DECODE_WIDTH-1 downto 0);
        output : out std_logic_vector(WIDTH_DATA-1 downto 0)
    );
end entity;

architecture arch_alu of alu is

begin

    process(clk, rst_n, input_A, input_B) 
    begin
        if rst_n = '0' then
            output <= (others=>'0');
        elsif rising_edge(clk) then
            if en = '1' then
                case decode is
                -- INstruction Type R
                    when ADD_select =>    -- ADD
                        output <= std_logic_vector(unsigned(input_A) + unsigned(input_B));
                        
                    when SUB_select =>    -- SUB
                        output <= std_logic_vector(unsigned(input_A) - unsigned(input_B));
                        
                    when SLL_select =>    -- SLL
                        output <= std_logic_vector(unsigned(input_A) sll integer(input_B));
                    
                    when SLT_select =>    -- SLT
                        output <= std_logic_vector(unsigned(input_A) slt integer(input_B));
                    
                    when SLTU_select =>    -- SLTU
                        output <= std_logic_vector(unsigned(input_A) sltu integer(input_B));
                    
                    when XOR_select =>    -- XOR
                        output <= input_A xor input_B;
                        
                    when SRL_select =>    -- SRL
                        if input_B(4 downto 0) = "11111" then
                            output <= (others=>'0'); 
                        else
                            output <= std_logic_vector(input_A(WIDTH_DATA downto 2**to_integer(unsigned(input_B(4 downto 0)))));
                            output(2**to_integer(unsigned(input_B(4 downto 0)))-1 downto 0) <=  (others=>'0');
                        end if;
                        
                    when SRA_select =>    -- SRA
                        output <= std_logic_vector(unsigned(input_A) sra 2**(to_integer(input_B(4 downto 0))));
                        
                    when OR_select =>    -- OR
                        output <= input_A or input_B;
                        
                    when AND_select =>    -- AND
                        output <= input_A and input_B;
                        
                    when others => null;
                
                end case;
            elsif en = '0' then
                output <= (others=>'0');
            end if;
        end if; 
    
    end process;
end architecture;