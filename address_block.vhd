
--cambiamenti nel branch 1
--cambiamento 2
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity address_block is 
port(ADDRESS: in std_logic_vector(7 downto 0);
		ADD_0: out std_logic;
		ADD_1: out std_logic;
		ADD_2: out std_logic;
		ADD_3: out std_logic
);
end address_block;

architecture behavior of address_block is

begin ---- begin architecture

ADD_0<= not(ADDRESS(0)) and not(ADDRESS(1));
ADD_1<= ADDRESS(0) and not(ADDRESS(1));
ADD_2<= not(ADDRESS(0)) and ADDRESS(1);
ADD_3<=ADDRESS(0) and ADDRESS(1);

end behavior;