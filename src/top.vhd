library ieee;
use ieee.std_logic_1164.all;

entity top is
end entity;

architecture arch_top of top is

component alu is 
end component;

component decode is 
end component;

component fetch is 
end component;

component program_register is 
end component;

component stack_register is 
end component;

component system_management is 
end component;

begin

impl_alu : alu;

impl_decode : decode;

impl_fetch : fetch;

impl_program_register : program_register;

impl_stack_register : stack_register;

impl_system_management : system_management;

end architecture;