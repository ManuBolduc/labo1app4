---------------------------------------------------------------------------------------------
--
--	Université de Sherbrooke 
--  Département de génie électrique et génie informatique
--
--	S4i - APP4 
--	
--
--	Auteurs: 		Marc-André Tétrault
--					Daniel Dalle
--					Sébastien Roy
-- 
---------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mips_datapath_unicycle is
Port ( 
		clk 			: in std_ulogic;
		reset 			: in std_ulogic;

		i_alu_funct   	: in std_ulogic_vector(3 downto 0);
		i_RegWrite    	: in std_ulogic;
		i_RegDst      	: in std_ulogic;
		i_MemtoReg    	: in std_ulogic;
		i_branch      	: in std_ulogic;
		i_ALUSrc      	: in std_ulogic;
		i_MemWrite	  	: in std_ulogic;
        i_addi          : in std_ulogic;		
		i_SignExtend 	: in std_ulogic;

		o_Instruction 	: out std_ulogic_vector (31 downto 0);
		o_PC		 	: out std_ulogic_vector (31 downto 0)
);
end mips_datapath_unicycle;

architecture Behavioral of mips_datapath_unicycle is

component MUX is
generic(nbits: integer:=32);
    Port ( i_A : in STD_LOGIC_VECTOR ((nbits-1) downto 0);
           i_B : in STD_LOGIC_VECTOR ((nbits-1) downto 0);
           i_sel : in STD_LOGIC;
           o_ALU : out STD_LOGIC_VECTOR ((nbits-1) downto 0));
end component;

component MemInstructions is
    Port ( i_addresse : in std_ulogic_vector (31 downto 0);
           o_instruction : out std_ulogic_vector (31 downto 0));
end component;

component BancRegistres is
    Port ( clk : in std_ulogic;
           reset : in std_ulogic;
           i_RS1 : in std_ulogic_vector (4 downto 0);
           i_RS2 : in std_ulogic_vector (4 downto 0);
           i_Wr_DAT : in std_ulogic_vector (31 downto 0);
           i_WDest : in std_ulogic_vector (4 downto 0);
           i_WE : in std_ulogic;
           o_RS1_DAT : out std_ulogic_vector (31 downto 0);
           o_RS2_DAT : out std_ulogic_vector (31 downto 0));
end component;

component alu is
    Port ( i_a 			: in std_ulogic_vector (31 downto 0);
           i_b 			: in std_ulogic_vector (31 downto 0);
           i_alu_funct	: in std_ulogic_vector (3 downto 0);
		   i_shamt 		: in std_ulogic_vector (4 downto 0);
           o_result 	: out std_ulogic_vector (31 downto 0);
           o_zero 		: out std_ulogic);
end component;

component SignExtender is
    Port ( i_immediate : in STD_LOGIC_VECTOR (15 downto 0);
           o_immediate : out STD_LOGIC_VECTOR (31 downto 0));
end component;

    signal r_PC          : std_ulogic_vector(31 downto 0);
    
    signal s_Instruction : std_ulogic_vector(31 downto 0);
    signal s_opcode      : std_ulogic_vector(5 downto 0);
    signal s_RS          : std_ulogic_vector(4 downto 0);
    signal s_RT          : std_ulogic_vector(4 downto 0);
    signal s_RD          : std_ulogic_vector(4 downto 0);
    signal s_shamt       : std_ulogic_vector(4 downto 0);
    signal s_instr_funct : std_ulogic_vector(5 downto 0);
    signal s_reg_data1        : std_ulogic_vector(31 downto 0);
    signal s_reg_data2        : std_ulogic_vector(31 downto 0);
    signal s_AluResult             : std_ulogic_vector(31 downto 0);
    signal s_mux_alu             : std_ulogic_vector(31 downto 0);
    signal s_signExtender_mux             : std_ulogic_vector(31 downto 0);
    signal s_instructions_register             : std_ulogic_vector(4 downto 0);
begin

------------------------------------------------------------------------
-- simplification des noms de signaux et transformation des types
------------------------------------------------------------------------
s_opcode        <= s_Instruction(31 downto 26);
s_RS            <= s_Instruction(25 downto 21);
s_RT            <= s_Instruction(20 downto 16);
s_RD            <= s_Instruction(15 downto 11);
s_shamt         <= s_Instruction(10 downto 6);
s_instr_funct   <= s_Instruction(5 downto 0);
o_pc            <= r_PC;
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Compteur de programme
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if(reset = '1') then
            r_PC <= X"00400000";
        else
            r_PC <= std_ulogic_vector(unsigned(r_PC) + 4);
        end if;
    end if;
end process;
------------------------------------------------------------------------

-- Mémoire d'instructions
------------------------------------------------------------------------
inst_MemInstr: MemInstructions
Port map ( 
	i_addresse => r_PC,
    o_instruction => s_Instruction
    );

-- branchement vers le décodeur d'instructions
o_instruction <= s_Instruction;

------------------------------------------------------------------------
-- Banc de Registres
------------------------------------------------------------------------
inst_Registres: BancRegistres 
port map ( 
	clk          => clk,
	reset        => reset,
	i_RS1        => s_RS,
	i_RS2        => s_RT,
	i_Wr_DAT     => s_AluResult,
	i_WDest      => s_instructions_register,
	i_WE         => i_RegWrite,
	o_RS1_DAT    => s_reg_data1,
	o_RS2_DAT    => s_reg_data2
	);
       
------------------------------------------------------------------------
-- ALU
------------------------------------------------------------------------                  
inst_alu: alu
    Port map( 
        i_a         => s_reg_data1,
        i_b         => s_mux_alu,
        i_alu_funct => i_alu_funct,
        i_shamt     => s_shamt,
        o_result    => s_AluResult,
        o_zero      => open
        );


------------------------------------------------------------------------
-- MUX
------------------------------------------------------------------------

inst_mux_1: MUX
generic map (nbits => 32)
    Port map(
        i_A => s_reg_data2,
        i_B => s_signExtender_mux,
        i_sel => i_addi,
        o_ALU => s_mux_alu
        );

inst_mux_2: MUX
generic map (nbits => 5)
    Port map(
        i_A => s_RD,
        i_B => s_RT,
        i_sel => i_addi,
        o_ALU => s_instructions_register  
        );       
        
------------------------------------------------------------------------
-- Sign Extender
------------------------------------------------------------------------

inst_signExtender: signExtender
    Port map(
        i_immediate => s_Instruction(15 downto 0),
        o_immediate => s_signExtender_mux
        );
end Behavioral;