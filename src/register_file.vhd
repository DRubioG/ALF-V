library ieee;
use ieee.std_logic_1164.all;

entity register_file is
    generic (
        WIDTH : integer := 32
    );
    port (
        clk : in std_logic;
        rst_n : in std_logic;
        
        A1 : in std_logic_vector(4 downto 0);
        A2 : in std_logic_vector(4 downto 0);
        Rd : in std_logic_vector(4 downto 0);
        
        WE3 : in std_logic;
        WD3 : in std_logic;
        
        RD1 : out std_logic_vector(WIDTH-1 downto 0);
        RD2 : out std_logic_vector(WIDTH-1 downto 0) 
    );
end entity;