LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity CRC_INTERFACE is 
port(
	IN_DIN: in std_logic_vector(15 downto 0);
	ADDRESS: in std_logic_vector(7 downto 0);
	RD_EN, WR_EN, RST,  CLK, CS, OE: in std_logic;
	OUT_DOUT: out std_logic_vector(15 downto 0)
	);
end CRC_INTERFACE;





architecture behavior of CRC_INTERFACE is

--SIGNALS-----------------------------------------------
--stati
type state_type is(RESET, LOAD_DIN, LOAD_R_REG, SHIFT, IDLE_SHIFT, UPDATE_R_REG, IDLE_R_REG, LOAD_CRC, READ_CRC_OUT, LOAD_CONTROL_REG, RESET_CRC, READ_STATUS, IDLE);
signal P_state, N_state: state_type;

--segnali di comando
signal LD_DATA_IN_REG, RST_DATA_IN_REG: std_logic;
signal LD_CONTROL_REG, RST_CONTROL_REG: std_logic;
signal SE_R_REG, LD_R_REG: std_logic;
signal LD_CRC_OUT_REG, RST_CRC_OUT_REG: std_logic;
signal OE_BUFFER1, OE_BUFFER2: std_logic;
signal S_MUX, S_MUX_r: std_logic;
signal RST_STATUS_REG, LD_STATUS_REG: std_logic;
signal CNT_RST: std_logic;
signal XOR_EN, ADD_0, ADD_1, ADD_2, ADD_3, TC: std_logic;
signal CONTROL_OUT: std_logic_vector(15 downto 0);

--COMPONENTS-------------------------------------------.
component CRC is 
port(
	DATA_IN_REG: in std_logic_vector(15 downto 0); --dato che viene dal DIN_REG
	ADDRESS: in std_logic_vector(7 downto 0); --indirizzo che viene dall'ADD_REG
	CLK: in std_logic;
	LD_DATA_IN_REG, RST_DATA_IN_REG: in std_logic;
   LD_CONTROL_REG, RST_CONTROL_REG: in std_logic;
	SE_R_REG, LD_R_REG: in std_logic;
   LD_CRC_OUT_REG, RST_CRC_OUT_REG: in std_logic;
   S_MUX, S_MUX_r: in std_logic;
   RST_STATUS_REG, LD_STATUS_REG: in std_logic;
   OE_BUFFER1, OE_BUFFER2: in std_logic;
	CNT_RST: in std_logic;
	
	XOR_EN, ADD_0, ADD_1, ADD_2, ADD_3, TC: out std_logic;
	DATA_OUT, CONTROL_OUT : out std_logic_vector(15 downto 0) --Dato in uscita che viene dal DATA_OUT_REG
	);
end component;




--begin architecture
begin

--STATE_UPDATE
state_update: process(CLK, RST)

begin
	if (RST ='1') then -- reset asincrono attivo alto
		P_state <= RESET;
	elsif (CLK'event and CLK = '1') then -- fronte di salita del CLK
		P_state <= N_state;
	end if;

end process;


--STATE_ASSIGNMENT
state_assignment: process(P_state, XOR_EN, ADD_0, ADD_1, ADD_2, ADD_3, TC, CONTROL_OUT, CS)

begin
		case(P_state) is
		
		WHEN RESET => N_state <= IDLE;
		
		WHEN IDLE => if CS = '1' then
							if ADD_0 = '1' then
								if WR_EN = '1' then N_state <= LOAD_DIN;
								else N_state <= IDLE;
								end if;
								
							elsif ADD_1 = '1' then
								if RD_EN = '1' then N_state <= READ_CRC_OUT;
								else N_state <= IDLE;
								end if;
								
							elsif ADD_2 = '1' then
								if WR_EN = '1' then N_state <= LOAD_CONTROL_REG;
								else N_state <= IDLE;
								end if;
							
							elsif ADD_3 = '1' then
								if RD_EN = '1' then N_state <= READ_STATUS;
								else N_state <= IDLE;
								end if;
							end if;
						else N_state <= IDLE;
						end if;
		
		WHEN LOAD_DIN => N_state <= LOAD_R_REG;
		
		WHEN LOAD_R_REG => N_state <= SHIFT;
		
		WHEN SHIFT => N_state <= IDLE_SHIFT;
								 
		WHEN IDLE_SHIFT => if XOR_EN = '1' then N_state <= UPDATE_R_REG;
								 else N_state <= IDLE_R_REG;
								 end if;
								 
		WHEN UPDATE_R_REG => N_state <= IDLE_R_REG;
		
		WHEN IDLE_R_REG => if TC = '1' then N_state <= LOAD_CRC;
								 else N_state <= SHIFT;
								 end if;
		
		WHEN LOAD_CRC => N_state <= IDLE;
		
		WHEN READ_CRC_OUT => N_state <= IDLE;
		
		WHEN LOAD_CONTROL_REG => if CONTROL_OUT(0) = '1' then N_state <= IDLE;
									    else N_state <= RESET_CRC;
										 end if;
		
		WHEN RESET_CRC => N_state <= IDLE;
		
		WHEN READ_STATUS => N_state <= IDLE;
		
		WHEN others => N_state <= RESET;

		end case;

end process;



--CONTROL_UNIT
control_unit: process(P_state)
begin 

--default command
LD_DATA_IN_REG<='0';
RST_DATA_IN_REG<='0';
LD_CONTROL_REG<='0';
RST_CONTROL_REG<='0';
SE_R_REG<='0';
LD_R_REG<='0';
LD_CRC_OUT_REG<='0';
RST_CRC_OUT_REG<='0';
S_MUX<='0';
S_MUX_r<='0';
RST_STATUS_REG<='0';
LD_STATUS_REG<='0';
OE_BUFFER1<='0'; 
OE_BUFFER2<='0';
CNT_RST<='0';

  case(P_state) is
  
  when RESET=> RST_DATA_IN_REG<='1';
       RST_CONTROL_REG<='1';
       RST_CRC_OUT_REG<='1';
       RST_STATUS_REG<='1';
       CNT_RST<='1';
  
  when LOAD_DIN=> LD_DATA_IN_REG<='1';
        S_MUX<='1';
        LD_STATUS_REG<='1';
  
  when LOAD_R_REG=> S_MUX_R<='1';
        LD_R_REG<='1';
  
  when SHIFT=> SE_R_REG<='1';
  
  when IDLE_SHIFT => ---default
  
  when UPDATE_R_REG=> LD_R_REG<='1';
  
  when IDLE_R_REG=> ---default
  
  when LOAD_CRC => LD_CRC_OUT_REG<= '1';
         LD_STATUS_REG<='1';
         CNT_RST<='1';
  
  when READ_CRC_OUT=> OE_BUFFER1<='1';
  
  when LOAD_CONTROL_REG=> LD_CONTROL_REG<='1';
  
  when RESET_CRC=> RST_CRC_OUT_REG<='1';
         RST_DATA_IN_REG<='1';
         
  when READ_STATUS=> OE_BUFFER2<='1';
  
  when IDLE=> 
  
  when others=> --default
  
  end case;

end process;


CRC_INT: CRC port map(
DATA_IN_REG=> IN_DIN,
ADDRESS=> ADDRESS,
CLK=> CLK,
LD_DATA_IN_REG=>LD_DATA_IN_REG,
RST_DATA_IN_REG=>RST_DATA_IN_REG,
LD_CONTROL_REG=>LD_CONTROL_REG,
RST_CONTROL_REG=>RST_CONTROL_REG,
SE_R_REG=>SE_R_REG, 
LD_R_REG=>LD_R_REG,
LD_CRC_OUT_REG=>LD_CRC_OUT_REG,
RST_CRC_OUT_REG=>RST_CRC_OUT_REG,
S_MUX=>S_MUX,
S_MUX_r=>S_MUX_r,
RST_STATUS_REG=>RST_STATUS_REG,
LD_STATUS_REG=>LD_STATUS_REG,
OE_BUFFER1=>OE_BUFFER1,
OE_BUFFER2=>OE_BUFFER2,
CNT_RST=>CNT_RST,
XOR_EN=>XOR_EN,
ADD_0=>ADD_0,
ADD_1=>ADD_1,
ADD_2=>ADD_2,
ADD_3=>ADD_3,
TC=>TC,
DATA_OUT=>OUT_DOUT,
CONTROL_OUT=>CONTROL_OUT 
);


end behavior;