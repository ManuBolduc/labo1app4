----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/18/2021 02:58:18 PM
-- Design Name: 
-- Module Name: SignExtender - Behavioral
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

entity SignExtender is
    Port ( i_immediate : in STD_LOGIC_VECTOR (15 downto 0);
           o_immediate : out STD_LOGIC_VECTOR (31 downto 0));
end SignExtender;

architecture Behavioral of SignExtender is

begin
    o_immediate(31 downto 16) <= (others => i_immediate(15));
    o_immediate(15 downto 0) <= i_immediate;
end Behavioral;
