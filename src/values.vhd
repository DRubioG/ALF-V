library ieee;
use ieee.std_logic_1164.all;

package values is
    constant INSTRUCTIONS_WIDTH : integer := 7;
    constant ALU_WIDTH : integer := 10;
    constant DECODE_WIDTH : integer := 3;
    constant WIDTH_MUX : integer := 3;


-- Instructions constants
    subtype instructions_type is std_logic_vector(INSTRUCTIONS_WIDTH-1 downto 0);
    constant R_type     : instructions_type := "0110011";
    constant I_type     : instructions_type := "0000011";
    constant I2_type    : instructions_type := "0010011";
    constant S_type     : instructions_type := "1110011";
    constant B_type     : instructions_type := "1100011";
    constant U_type     : instructions_type := "0010111";
    constant J_type     : instructions_type := "1101111";


-- Decoder constants
    subtype decode_type is std_logic_vector(WIDTH_MUX-1 downto 0);
    constant ADD_SUB_OP     : decode_type := "000";
    constant SLL_OP         : decode_type := "001";
    constant SLT_OP         : decode_type := "010";
    constant SLTU_OP        : decode_type := "011";
    constant XOR_OP         : decode_type := "100";
    constant SRL_SRA_OP     : decode_type := "101";
    constant OR_OP          : decode_type := "110";
    constant AND_OP         : decode_type := "111";

    constant ADDI_OP        : decode_type := "000";
    constant SHAMT1_OP      : decode_type := "001";
    constant SLTI_OP        : decode_type := "010";
    constant SLTIU_OP       : decode_type := "011";
    constant XORI_OP        : decode_type := "100";
    constant SHAMT2_OP      : decode_type := "101";
    constant ORI_OP         : decode_type := "110";
    constant ANDI_OP        : decode_type := "111";


-- Alu constants
    subtype alu_type is std_logic_vector(ALU_WIDTH-1 downto 0);
    constant ADD_select     : alu_type := (0=>'1',others=>'0');
    constant SUB_select     : alu_type := (1=>'1',others=>'0');
    constant SLL_select     : alu_type := (2=>'1',others=>'0');
    constant SLT_select     : alu_type := (3=>'1',others=>'0');
    constant SLTU_select    : alu_type := (4=>'1',others=>'0');
    constant XOR_select     : alu_type := (5=>'1',others=>'0');
    constant SRL_select     : alu_type := (6=>'1',others=>'0');
    constant SRA_select     : alu_type := (7=>'1',others=>'0');
    constant OR_select      : alu_type := (8=>'1',others=>'0');
    constant AND_select     : alu_type := (9=>'1',others=>'0');

end package;