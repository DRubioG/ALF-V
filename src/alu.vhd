library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    generic (
        WIDTH_DATA : integer := 32;
        DECODE_WIDTH : integer := 3
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        input_A : in std_logic_vector(WIDTH_DATA-1 downto 0);
        input_B : in std_logic_vector(WIDTH_DATA-1 downto 0);
        imm : in std_logic_vector(10 downto 0);
        decode : in std_logic_vector(DECODE_WIDTH-1 downto 0);
        output : out std_logic_vector(WIDTH_DATA-1 downto 0)
    );
end entity;

architecture arch_alu of alu is

begin
    process(clk, rst, input_A, input_B) 
    variable value : integer;
    begin
        if rst = '1' then
            output <= (others=>'0');
        elsif rising_edge(clk) then
            
            case decode is
            -- INstruction Type R
                when "0000000001" =>    -- ADD
                    output <= std_logic_vector(unsigned(input_A) + unsigned(input_B));
                    
                when "0000000010" =>    -- SUB
                    output <= std_logic_vector(unsigned(input_A) - unsigned(input_B));
                    
                when "0000000100" =>    -- SLL
                    output <= std_logic_vector(unsigned(input_A) sll integer(input_B));
                
                when "0000001000" =>    -- SLT
                    output <= std_logic_vector(unsigned(input_A) slt integer(input_B));
                
                when "0000010000" =>    -- SLTU
                    output <= std_logic_vector(unsigned(input_A) sltu integer(input_B));
                
                when "0000100000" =>    -- XOR
                    output <= input_A xor input_B;
                    
                when "0001000000" =>    -- SRL
                    if input_B(4 downto 0) = "11111" then
                        output <= (others=>'0'); 
                    else
                        output <= std_logic_vector(input_A(WIDTH_DATA downto 2**to_integer(unsigned(input_B(4 downto 0)))));
                        output(2**to_integer(unsigned(input_B(4 downto 0)))-1 downto 0) <=  (others=>'0');
                    end if;
                    
                when "0010000000" =>    -- SRA
                    output <= std_logic_vector(unsigned(input_A) sra 2**(to_integer(input_B(4 downto 0))));
                    
                when "0100000000" =>    -- OR
                    output <= input_A or input_B;
                    
                when "1000000000" =>    -- AND
                    output <= input_A and input_B;
                    
                when others => null;
            
            end case;
        end if; 
    
    end process;
end architecture;