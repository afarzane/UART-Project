library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;


entity transmitter is
	
	port(
		RTS				:	in std_logic;
		clk_baud			:	in std_logic;
		reset				:	in std_logic;
		data_packet		:	in std_logic_vector(7 downto 0);
		CTS				:	out std_logic;
		TX_OUT			:	out std_logic
	);

end entity;



architecture bhv of transmitter is

	-- States required for transmitting data	
	type type_state is (idle, start, fill, parity, stop);
	signal current_state : type_state := idle;
	
begin
	
	-- Transmitter Process
	
	process(reset, clk_baud)
		
		-- Counter for knowing end of data
		variable counter : integer := 7;
		
		-- Counter for number of 1's in data (even parity)
		variable even_cnt : integer := 0;
	
	begin
	
		if (reset = '0') then
		
			current_state <= idle;
			counter := 7;
			even_cnt := 0;
			TX_OUT <= '1';
			CTS <= '0';
			
		elsif (rising_edge(clk_baud)) then
		
			case current_state is
			
				when idle =>
				-- If the handshake signal is activated (Receiver asking for data), then begin transmitting data, else remain idle
					if	(RTS = '1')	then
						CTS <= '1';
						current_state <= start;
					else
						current_state <= idle;
					end if;
					
				when start =>
				-- Set all counters to 0 and send the start bit
					counter := 7;
					even_cnt := 0;
					TX_OUT <= '0';
					current_state <= fill;
				
				when fill =>
				-- Send the bit that you are currently at
					TX_OUT <= data_packet(counter);
					
				-- Check if the bit is a 1 or 0 (For creating a parity bit in the next state)
					if (data_packet(counter) = '1') then
						even_cnt := even_cnt + 1;
					end if;
				
				-- Check to see if you are at the end of your byte. If not, increment index and continue, else move onto parity creation.
					if (counter = 0) then
						current_state <= parity;
					else
						counter := counter - 1;
						current_state <= fill;
					end if;
					
				when parity =>
				-- If parity counter is even, then parity bit is 1. Else, parity bit is 0
					if ((even_cnt mod 2) = 0) then
						TX_OUT <= '1';
					else
						TX_OUT <= '0';
					end if;
					
					current_state <= stop;
					
				when stop =>
					TX_OUT <= '1'; -- Stop bit
					CTS <= '0';
					current_state <= stop;
			
			end case;
		
		end if;
	
	end process;

end architecture;