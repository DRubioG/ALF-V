library ieee;
use ieee.std_logic_1164.all;

entity inst_data_memory is
    generic (
        WIDTH : integer := 32
    );
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        
        A : in std_logic_vector(WIDTH-1 downto 0);
        WE : in std_logic;
        WD : in std_logic;
        
        RD : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture arch_inst_data_memory of inst_data_memory is

begin

end architecture;