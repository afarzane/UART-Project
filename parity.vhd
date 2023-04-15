library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity parity is

	port(
	
		input_data		:	in std_logic_vector(7 downto 0);
		
		parity_bit		:	out std_logic
		
	);

end entity;


architecture bhv of parity is

begin

	



end architecture;