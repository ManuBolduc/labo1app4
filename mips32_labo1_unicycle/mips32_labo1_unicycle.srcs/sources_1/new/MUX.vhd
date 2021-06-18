----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/18/2021 02:35:04 PM
-- Design Name: 
-- Module Name: MUX - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUX is
generic(nbits: integer:=32);
    Port ( i_A : in STD_LOGIC_VECTOR ((nbits-1) downto 0);
           i_B : in STD_LOGIC_VECTOR ((nbits-1) downto 0);
           i_sel : in STD_LOGIC;
           o_ALU : out STD_LOGIC_VECTOR ((nbits-1) downto 0));
end MUX;

architecture Behavioral of MUX is

begin
process(i_sel,i_A, i_B) 
begin
if(i_sel = '0') then
    o_ALU <= i_A;
else
    o_ALU <= i_B;
end if;
end process;
end Behavioral;
