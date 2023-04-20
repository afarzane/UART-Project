library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;


entity baud_gen is

	generic(
		CLOCK			: 	integer := 50000000; -- Clock frequency that we use to generate Baud rate
		BAUD_RATE	:	integer := 9600 -- Our Baud rate to transmit/receive bits
	);

	port(
	
		clk_in		:	in std_logic;
		reset			:	in std_logic;
		
		baud_out		:	out std_logic
	
	);

end entity;


architecture bhv of baud_gen is

	-- signal count_reg	:	unsigned(15 downto 0);
	-- signal count		:	unsigned(15 downto 0);

begin

	process(reset, clk_in)
	
		variable count : integer := 0;
	
	begin
		
		if	(reset = '0') then
			
			count := 0; -- Reset counter
			baud_out <= '0'; -- Reset baud rate clock
		
		elsif (rising_edge(clk_in)) then
			
			-- If we are at Baud rate, then...
			-- (CLOCK/(16*BAUD_RATE))-1
			if(count = 15) then
			
				count := 0; -- Reset counter
				baud_out <= '1'; -- Activate baud_rate clock
			
			else
			
				count := count + 1; -- Else increment counter by one
				baud_out <= '0'; -- And maintain a baud clock of 0
	
			end if;
	
		end if;
	
	end process;

end architecture;