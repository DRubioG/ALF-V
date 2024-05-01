library ieee;
use ieee.std_logic_1164.all;

entity decode is
    generic (
        WIDTH : integer := 32;
        WIDTH_OP : integer := 6;
        WIDTH_MUX : integer := 3
    );
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        en : in std_logic;
        inst : in std_logic_vector(WIDTH-1 downto 0);
        inst_ok : in std_logic;
        rs1 : out std_logic_vector(4 downto 0);
        rs2 : out std_logic_vector(4 downto 0);
        rd : out std_logic_vector(4 downto 0);
        imm : out std_logic_vector(10 downto 0);
        operation : out std_logic_vector(3 downto 0);
        operation_ok : out std_logic
    );
end entity;

architecture arch_decoder of decode is

signal type_inst : std_logic_vector(6 downto 0);
signal type_r : std_logic_vector(4 downto 0);

begin
    
    
    process(clk, rst_n, inst_ok)
    begin
        if rst_n = '0' then
            
        elsif rising_edge(clk) then
            if en = '1' then
                type_inst <= inst(6 downto 0);
                type_r <= inst(14 downto 12);
                rs1 <= inst(19 downto 15);
                imm <= (others=>'0');
                rd <= inst(11 downto 7);
                if inst_ok = '1' then
                    case type_inst is

                        when R_type =>
                            rs2 <= inst(19 downto 15);
                            case type_r is
                            
                                when ADD_SUB_OP =>
                                    if inst(30) = '0' then  
                                        operation <= ADD_select;     -- ADD
                                    elsif inst(30) = '1' then
                                        operation <= SUB_select;     -- SUB
                                    end if;

                                when SLL_OP => 
                                    operation <= SLL_select;     -- SLL

                                when SLT_OP =>
                                    operation <= SLT_select;     -- SLT

                                when SLTU_OP =>
                                    operation <= SLTU_select;     -- SLTU

                                when XOR_OP =>
                                    operation <= XOR_select;     -- XOR

                                when SRL_SRA_OP =>
                                    if inst(30) = '0' then  
                                        operation <= SRL_select;     -- SRL
                                    elsif inst(30) = '1' then
                                        operation <= SRA_select;     -- SRA
                                    end if;

                                when OR_OP =>
                                    operation <= OR_select;     -- OR

                                when AND_OP =>
                                    operation <= AND_select;     -- AND
                            end case;
                            
                        when I_type =>
                            imm <= inst(31 downto 20);
                            case type_r is
                            
                                when ADDI_OP =>
                                    operation <= ADD_select;     -- ADDI

                                when SHAMT1_OP =>
                                    operation <= SLL_select;     -- SLL

                                when SLTI_OP =>
                                    operation <= SLT_select;     -- SLTI

                                when SLTIU_OP =>
                                    operation <= SLTU_select;     -- SLTUI

                                when XORI_OP =>
                                    operation <= XOR_select;     -- XORI

                                when SHAMT2_OP =>
                                    if inst(30) = '0' then  
                                        operation <= SRL_select;     -- SRLI
                                    elsif inst(30) = '1'then
                                        operation <= SRA_select;     -- SRAI
                                    end if;

                                when ORI_OP =>
                                    operation <= OR_select;     -- ORI

                                when ANDI_OP =>
                                    operation <= AND_select;     -- ANDI
                            end case;
                            
                    end case;    
                end if;
            elsif en = '0' then
                
            end if;
        end if;
    end process;
    
end architecture;