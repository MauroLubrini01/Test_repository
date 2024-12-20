LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


entity R_REG is
port(
CLK, SH_EN, LD_EN: in std_logic;
IN_SERIAL: in std_logic;
IN_PARALLEL: in std_logic_vector(15 downto 0);
OUT_SERIAL: out std_logic;
OUT_PARALLEL: out std_logic_vector(15 downto 0)
);
end R_REG;


architecture behavior of R_REG is
--signals
signal memory: std_logic_vector(15 downto 0);

--components


--begin architecture
begin

shift: process(CLK, SH_EN, LD_EN)
begin
if (CLK'event and CLK = '1') then
	if (SH_EN = '1') then
		OUT_SERIAL <= memory(15);
		memory <= memory(14 downto 0) & IN_SERIAL;
	elsif (LD_EN = '1') then
		memory<= IN_PARALLEL;
	end if;
end if;
OUT_PARALLEL <= memory;
end process shift;



end behavior;