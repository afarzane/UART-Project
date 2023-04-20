library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;


entity transmitter is
	
	port(
		CTS				:	in std_logic;
		RX_err			:	in	std_logic;
		clk_baud			:	in std_logic;
		reset				:	in std_logic;
		data_packet		:	in std_logic_vector(7 downto 0);
		RTS				:	out std_logic;
		TX_OUT			:	out std_logic
	);

end entity;



architecture bhv of transmitter is

	-- States required for transmitting data	
	type type_state is (idle, fill, parity, stop);
	signal current_state : type_state := idle;
	
	signal even_cnt_sig : unsigned(7 downto 0);
	signal data_framed : std_logic_vector(8 downto 0);
	--signal parity_buffer : std_logic;
	
begin
	
	-- Transmitter Process
	
	data_framed <= '0' & data_packet;
	
	process(reset, clk_baud, CTS)
		
		-- Counter for knowing end of data
		variable counter : integer := 8;
		
		-- Counter for number of 1's in data (even parity)
		variable even_cnt : integer := 0;
		
		variable parity_buffer : std_logic;
	
	begin
	
		if (reset = '0') then
			counter := 8;
			even_cnt := 0;
			TX_OUT <= '1';
			RTS <= '0';
			current_state <= idle;
			
		elsif (rising_edge(clk_baud)) then
		
			case current_state is
			
				when idle =>
				RTS <= '1';
				TX_OUT <= '1';
				-- If the handshake signal is activated (Receiver asking for data), then begin transmitting data, else remain idle
					counter := 8;
					even_cnt := 0;
					if	(CTS = '1')	then
						--RTS <= '0';
						current_state <= fill;
					else
						current_state <= idle;
					end if;
				
				when fill =>
					
					-- Send the bit that you are currently at
					if (CTS = '1') then
						TX_OUT <= data_framed(counter);
						
					-- Check if the bit is a 1 or 0 (For creating a parity bit in the next state)
						if (data_framed(counter) = '1') then
							even_cnt := even_cnt + 1;
						end if;
					
					-- Check to see if you are at the end of your byte. If not, increment index and continue, else move onto parity creation.
						if (counter = 0) then
							
							current_state <= parity;
						else
							counter := counter - 1;
							current_state <= fill;
						end if;
						
					else
						current_state <= fill;
					end if;
				
					
				when parity =>
				-- If parity counter is even, then parity bit is 1. Else, parity bit is 0
					if ((even_cnt mod 2) = 0) then
						parity_buffer := '1';
					else
						parity_buffer := '0';
					end if;
					
					even_cnt_sig <= to_unsigned(even_cnt, 8);
					
					--RTS <= '1';
					if (CTS ='1') then
						TX_OUT <= parity_buffer;
						current_state <= stop;
					else
						current_state <= parity;
					end if;
					
				when stop =>
					
					TX_OUT <= '1'; -- Stop bit
					--RTS <= '0';
				
				-- If there was an error, resend byte again. Else, move onto next byte
					if (RX_err = '1') then
						current_state <= idle;
					else
						current_state <= stop;
					end if;
				
			
			end case;
		
		end if;
	
	end process;

end architecture;