library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity receiver_tb is

end entity;

architecture bhv of receiver_tb is

	signal input : std_logic_vector(7 downto 0) := "01011010";
	signal output : std_logic_vector(7 downto 0);
	signal data_bit : std_logic := '1';
	signal clk : std_logic;
	signal reset : std_logic := '1';
	signal CTS : std_logic := '1';
	signal complete : std_logic;
	signal err : std_logic;
	signal RTS : std_logic;
	
	type type_state is (idle, start, read_data, parity_check, stop);
	signal current_state : type_state := idle;
	
begin

	receive : entity work.receiver(bhv)
		port map(
			CTS	=> CTS,
			clk_baud	=>	clk,
			reset	=> reset,
			TX_data_bit => data_bit,
			error_flag => err,
			complete_flag => complete,
			RTS	=> RTS,
			receiver_out => output
		
		);


	process(clk, reset)
		
		-- Counter for knowing end of data
		variable counter : integer := 0;
		
		-- Counter for number of 1's in data (even parity)
		variable even_cnt : integer := 0;
	
	begin
	
	
		if (reset = '0') then
		
			counter := 0;
			even_cnt := 0;
			current_state <= idle;
			
		elsif (rising_edge(clk)) then
			
			case current_state is
			
				when idle =>
				-- transmit ready
					CTS <= '1';
					if(RTS = '1')then
						current_state <= start;
					else
						current_state <= idle;
					end if;
					
				when start =>
					counter := 0;
					even_cnt := 0;
				
				-- start bit
					data_bit <= '0';
					current_state <= read_data;
				
				when read_data =>
					data_bit <= input(counter);
					
				
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
						data_bit <= '1';
					else
						data_bit <= '0';
					end if;
						
						
					current_state <= stop; -- Edit this state for error correction later
				
				when stop =>
				-- Set a complete flag to let the system know that data is fully read. Stop receiving
					CTS <= '0';
					current_state <= stop;
					
			end case;
	
		end if;
		
	end process;


end architecture;