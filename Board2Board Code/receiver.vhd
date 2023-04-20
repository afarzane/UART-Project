library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;


entity receiver is
	
	port(
		RTS				:	in std_logic;
		clk_baud			:	in std_logic;
		reset				:	in std_logic;
		TX_data_bit		:	in std_logic;
		error_flag		:	out std_logic;
		complete_flag	:	out std_logic;
		CTS				:	out std_logic;
		receiver_out	:	out std_logic_vector(7 downto 0) -- Output register
	);

end entity;


architecture bhv of receiver is

	-- States required for transmitting data	
	type type_state is (idle, start, read_data, parity_check, stop);
	signal current_state : type_state := idle;
	
begin

	process(clk_baud, reset, RTS)
		
		-- Counter for knowing end of data
		variable counter : integer := 0;
		
		-- Counter for number of 1's in data (even parity)
		variable even_cnt : integer := 0;
	
		-- Buffer output
		variable out_buffer : unsigned(7 downto 0);
		variable bit_buffer : unsigned(0 downto 0);
	
	begin
	
	receiver_out <= std_logic_vector(out_buffer);
	
		if (RTS = '0') then
		
			CTS <= '0';
			counter := 0;
			even_cnt := 0;
			current_state <= idle;
			
		elsif (rising_edge(clk_baud)) then
			
			case current_state is
			
				when idle =>
				-- When the transmitter is ready to send, read start bit
					if (RTS = '1') then
						CTS <= '1';
						current_state <= start;
					else
						current_state <= idle;
					end if;
					
				when start =>
					counter := 0;
					even_cnt := 0;
					
				-- CTS <= '0';
				-- If start bit is correct, then begin reading data
					if (TX_data_bit = '0') then
						out_buffer := "00000000";
						current_state <= read_data;
					else 
						-- CTS <= '1';
						current_state <= start;
					end if;
				
				when read_data =>
				-- Read data into the 8 bit register and shift it left by one
					
					bit_buffer := unsigned'("" & TX_data_bit);
					out_buffer := out_buffer + bit_buffer;
					if (counter <= 6) then
						out_buffer := shift_left(unsigned(out_buffer), 1);
					end if;
					
				-- Check if the bit is a 1 or 0 (For checking the parity bit in the next state)
					if (TX_data_bit = '1') then
						even_cnt := even_cnt + 1;
					end if;
				
				-- Check to see if you are at the end of your byte. If not, increment index and continue, else move onto parity creation.
					if (counter = 7) then
						current_state <= parity_check;
					else
						counter := counter + 1;
						current_state <= read_data;
					end if;
			
				when parity_check =>
				-- Check if parity is correct
					if ((even_cnt mod 2) = 0) then
						if (TX_data_bit = '1') then
							error_flag <= '0';
						else
							error_flag <= '1';
						end if;
						
						current_state <= stop;
						
					else
						if (TX_data_bit = '0') then
							error_flag <= '0';
						else
							error_flag <= '1';
						end if;
						
						current_state <= stop; -- Edit this state for error correction later
						
					end if;
				
				when stop =>
				-- Set a complete flag to let the system know that data is fully read. Stop receiving
					CTS <= '0';
					complete_flag <= '1';
					current_state <= stop;
					
			end case;
	
		end if;
		
	end process;

end architecture;

--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--library work;
--use work.all;
--
--
--entity receiver is
--	
--	port(
--		RTS				:	in std_logic;
--		clk_baud			:	in std_logic;
--		reset				:	in std_logic;
--		TX_data_bit		:	in std_logic;
--		error_flag		:	out std_logic;
--		complete_flag	:	out std_logic;
--		CTS				:	out std_logic;
--		receiver_out	:	out std_logic_vector(7 downto 0) -- Output register
--	);
--
--end entity;
--
--
--architecture bhv of receiver is
--
--	-- States required for transmitting data	
--	type type_state is (idle, start, read_data, parity_check, stop);
--	signal current_state : type_state := idle;
--	
--begin
--
--	process(clk_baud, reset, RTS)
--		
--		-- Counter for knowing end of data
--		variable counter : integer := 0;
--		
--		-- Counter for number of 1's in data (even parity)
--		variable even_cnt : integer := 0;
--	
--		-- Buffer output
--		variable out_buffer : unsigned(7 downto 0);
--		variable bit_buffer : unsigned(0 downto 0);
--	
--	begin
--	
--	receiver_out <= std_logic_vector(out_buffer);
--	
--		if (RTS = '0') then
--		
--			CTS <= '0';
--			counter := 0;
--			even_cnt := 0;
--			current_state <= idle;
--			
--		elsif (rising_edge(clk_baud)) then
--			
--			case current_state is
--			
--				when idle =>
--				-- When the transmitter is ready to send, read start bit
--					if (RTS = '1') then
--						CTS <= '1';
--						current_state <= start;
--					else
--						current_state <= idle;
--					end if;
--					
--				when start =>
--					counter := 0;
--					even_cnt := 0;
--					
--					CTS <= '0';
--				-- If start bit is correct, then begin reading data
--					if (TX_data_bit = '0') then
--						out_buffer := "00000000";
--						current_state <= read_data;
--					else 
--						CTS <= '1';
--						current_state <= start;
--					end if;
--				
--				when read_data =>
--				-- Read data into the 8 bit register and shift it left by one
--					
--					bit_buffer := unsigned'("" & TX_data_bit);
--					out_buffer := out_buffer + bit_buffer;
--					if (counter <= 6) then
--						out_buffer := shift_left(unsigned(out_buffer), 1);
--					end if;
--					
--				-- Check if the bit is a 1 or 0 (For checking the parity bit in the next state)
--					if (TX_data_bit = '1') then
--						even_cnt := even_cnt + 1;
--					end if;
--				
--				-- Check to see if you are at the end of your byte. If not, increment index and continue, else move onto parity creation.
--					if (counter = 7) then
--						current_state <= parity_check;
--					else
--						counter := counter + 1;
--						current_state <= read_data;
--					end if;
--			
--				when parity_check =>
--				-- Check if parity is correct
--					if ((even_cnt mod 2) = 0) then
--						if (TX_data_bit = '1') then
--							error_flag <= '0';
--						else
--							error_flag <= '1';
--						end if;
--						
--						current_state <= stop;
--						
--					else
--						if (TX_data_bit = '0') then
--							error_flag <= '0';
--						else
--							error_flag <= '1';
--						end if;
--						
--						current_state <= stop; -- Edit this state for error correction later
--						
--					end if;
--				
--				when stop =>
--				-- Set a complete flag to let the system know that data is fully read. Stop receiving
--					CTS <= '0';
--					complete_flag <= '1';
--					current_state <= stop;
--					
--			end case;
--	
--		end if;
--		
--	end process;
--
--end architecture;