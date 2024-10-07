library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


package program_package is
    
type program_type is array (7 downto 0) of std_logic_vector(31 downto 0);

constant program_pkg : program_type ;
    
    
end package;