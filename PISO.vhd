LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity PISO is 
	generic(N: integer := 16); 
	port (
		 clk: in std_logic;
		 se: in std_logic;
		 rst: in std_logic; 
		 en: in std_logic; 
		 in_data: in std_logic_vector(N-1 downto 0);
		 out_data: out std_logic
	 );
end PISO;


architecture behavior of PISO is

signal Q: std_logic_vector(N-1 downto 0);


begin ------begin architecture
	PROCESS (CLK, RST)
		BEGIN
			IF (RST = '1') THEN -- reset attivo alto
				Q <= (OTHERS => '0'); -- reset
				OUT_DATA <= 'Z'; -- uscita in alta impedenza
			ELSIF (clk'event and clk ='1') then
				IF EN = '1' then
					Q <= IN_DATA;
				elsif EN = '0' and SE='1' then
					OUT_DATA <= Q(15); --mando fuori il msb
					Q(N-1 downto 1) <= Q(N-2 downto 0);
					Q(0) <= '0';
				end if;
			END IF;
	END PROCESS;
	
end behavior;