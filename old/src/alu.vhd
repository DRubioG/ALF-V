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
constant zero : unsigned(31 downto 0) := (others=>'0');
begin

    process(clk, rst_n, en, input_A, input_B) 
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
                        if input_B = (input_B'range=>'0') then
                            output <= input_A;
                        else
                            output <= std_logic_vector(unsigned(input_A) sll to_integer(unsigned(input_B)));
                        end if;
                    
                    when SLT_select =>    -- SLT
                        if input_B(WIDTH_DATA-1) > input_A(WIDTH_DATA-1) then
                            output <= (others=>'0');
                        elsif input_B(WIDTH_DATA-1) < input_A(WIDTH_DATA-1) then
                            output <= (0=>'1', others=>'0');
                        else
                            if input_A(WIDTH_DATA-1) = '1' then
                                if input_B(WIDTH_DATA-2 downto 0) < input_A(WIDTH_DATA-2 downto 0) then
                                    output <= (0=>'1', others=>'0');
                                else
                                    output <= (others=>'0');
                                end if;
                            else
                                if input_B(WIDTH_DATA-2 downto 0) > input_A(WIDTH_DATA-2 downto 0) then
                                    output <= (0=>'1', others=>'0');
                                else
                                    output <= (others=>'0');
                                end if;
                            end if;
                        end if;
                    
                    when SLTU_select =>    -- SLTU
                        if input_B > input_A then
                            output <= (0=>'1', others=>'0');
                        else
                            output <= (others=>'0');
                        end if;
                    
                    when XOR_select =>    -- XOR
                        output <= input_A xor input_B;
                        
                    when SRL_select =>    -- SRL
                        if input_B(4 downto 0) = (input_B(4 downto 0)'range=>'1') then --"11111" then
                            output <= (others=>'0'); 
                        else                            
                            -- IMPROVE : output <= std_logic_vector(unsigned(input_A) srl 2**(to_integer(unsigned(input_B))));
                        end if;
                        
                    when SRA_select =>    -- SRL
                        if input_B = (input_B'range=>'0') then
                            output <= input_A;
                        else
                            output <= std_logic_vector(unsigned(input_A) srl to_integer(unsigned(input_B)));
                        end if;
                        
                    when OR_select =>    -- OR
                        output <= input_A or input_B;
                        
                    when AND_select =>    -- AND
                        output <= input_A and input_B;
                        
                    when others => 
                        output <= (others=>'0');
                
                end case;
            elsif en = '0' then
                output <= (others=>'0');
            end if;
        end if; 
    
    end process;
end architecture;