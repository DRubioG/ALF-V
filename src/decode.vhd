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


constant R : std_logic_vector(WIDTH_OP downto 0) := "0110011";
constant I : std_logic_vector(WIDTH_OP downto 0) := "0010011";

constant ADD_SUB_OP : std_logic_vector(WIDTH_MUX downto 0)  := "000";
constant SLL_OP : std_logic_vector(WIDTH_MUX downto 0)      := "001";
constant SLT_OP : std_logic_vector(WIDTH_MUX downto 0)      := "010";
constant SLTU_OP : std_logic_vector(WIDTH_MUX downto 0)     := "011";
constant XOR_OP : std_logic_vector(WIDTH_MUX downto 0)      := "100";
constant SRL_SRA_OP : std_logic_vector(WIDTH_MUX downto 0)  := "101";
constant OR_OP : std_logic_vector(WIDTH_MUX downto 0)       := "110";
constant AND_OP : std_logic_vector(WIDTH_MUX downto 0)      := "111";


constant ADDI_OP : std_logic_vector(WIDTH_MUX downto 0)     := "000";
constant SHAMT1_OP : std_logic_vector(WIDTH_MUX downto 0)   := "001";
constant SLTI_OP : std_logic_vector(WIDTH_MUX downto 0)     := "010";
constant SLTIU_OP : std_logic_vector(WIDTH_MUX downto 0)    := "011";
constant XORI_OP : std_logic_vector(WIDTH_MUX downto 0)     := "100";
constant SHAMT2_OP : std_logic_vector(WIDTH_MUX downto 0)   := "101";
constant ORI_OP : std_logic_vector(WIDTH_MUX downto 0)      := "110";
constant ANDI_OP : std_logic_vector(WIDTH_MUX downto 0)     := "111";


begin
    
    
    process(clk, rst_n, inst_ok)
    begin
        if rst_n = '0' then
            
        elsif rising_edge(clk) then
            type_inst <= inst(6 downto 0);
            type_r <= inst(14 downto 12);
            rs1 <= inst(19 downto 15);
            imm <= (others=>'0');
            rd <= inst(11 downto 7);
            if inst_ok = '1' then
                case type_inst is
                    when R =>
                        rs2 <= inst(19 downto 15);
                        case type_r is
                        
                            when ADD_SUB_OP =>
                                if inst(31 downto 25) = "0000000" then  
                                    operation <= (0=>'1', others=>'0');     -- ADD
                                elsif inst(31 downto 25) = "0100000" then
                                    operation <= (1=>'1', others=>'0');     -- SUB
                                end if;
                            when SLL_OP => 
                                operation <= (2=>'1', others=>'0');     -- SLL
                            when SLT_OP =>
                                operation <= (3=>'1', others=>'0');     -- SLT
                            when SLTU_OP =>
                                operation <= (4=>'1', others=>'0');     -- SLTU
                            when XOR_OP =>
                                operation <= (5=>'1', others=>'0');     -- XOR
                            when SRL_SRA_OP =>
                                if inst(31 downto 25) = "0000000" then  
                                    operation <= (6=>'1', others=>'0');     -- SRL
                                elsif inst(31 downto 25) = "0100000" then
                                    operation <= (7=>'1', others=>'0');     -- SRA
                                end if;
                            when OR_OP =>
                                operation <= (8=>'1', others=>'0');     -- OR
                            when AND_OP =>
                                operation <= (9=>'1', others=>'0');     -- AND
                        end case;
                        
                    when I =>
                        imm <= inst(31 downto 20);
                        case type_r is
                        
                            when ADDI_OP =>
                                operation <= (0=>'1', others=>'0');     -- ADDI
                            when SHAMT1_OP =>
                                operation <= (2=>'1', others=>'0');     -- SLL
                            when SLTI_OP =>
                                operation <= (3=>'1', others=>'0');     -- SLTI
                            when SLTIU_OP =>
                                operation <= (4=>'1', others=>'0');     -- SLTUI
                            when XORI_OP =>
                                operation <= (5=>'1', others=>'0');     -- XORI
                            when SHAMT2_OP =>
                                if inst(31 downto 25) = "0000000" then  
                                    operation <= (6=>'1', others=>'0');     -- SRLI
                                elsif inst(31 downto 25) = "0100000" then
                                    operation <= (7=>'1', others=>'0');     -- SRAI
                                end if;
                            when ORI_OP =>
                                operation <= (8=>'1', others=>'0');     -- ORI
                            when ANDI_OP =>
                                operation <= (9=>'1', others=>'0');     -- ANDI
                        end case;
                        
                end case;    
            end if;
        end if;
    end process;
    
end architecture;