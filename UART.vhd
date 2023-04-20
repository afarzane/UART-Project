library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity UART is
	
	port(
		CLOCK_50			:	in std_logic;
		KEY				:	in std_logic_vector(3 downto 0);
		SW					:	in std_logic_vector(7 downto 0);
		--UART_RXD			:	in std_logic;
		--UART_RTS			:	in std_logic;
		--UART_TXD			:	out std_logic;
		--UART_CTS			:	out std_logic;
		LEDR				:	out std_logic_vector(17 downto 0)
	);

end entity;


architecture bhv of UART is
	
	signal baud_sig : std_logic; -- Signal for connecting baudrate generator to transmitter/receiver
	
	-- Temporary testing signals
	signal RTS_temp	:	std_logic;
	signal CTS_temp	:	std_logic;
	signal out_bit		:	std_logic;
	signal err			:	std_logic;
	signal complete	:	std_logic;
	signal output_LED :	std_logic_vector(7 downto 0);

begin

	-- Instantiation of Baud rate generator component
	baud_rate_gen	:	entity work.baud_gen(bhv)
		port map(
			clk_in => CLOCK_50,
			reset => KEY(0),
			baud_out => baud_sig
		);
	
	-- Transmitter
	transmitter_1	:	entity work.transmitter(bhv)
		port map(
			RTS => RTS_temp,
			clk_baud => baud_sig,
			reset => KEY(0),
			data_packet => SW(7 downto 0),
			CTS => CTS_temp,
			TX_OUT => out_bit
		);
	
	-- Receiver
	receiver_1	:	entity work.receiver(bhv)
		port map(
			CTS => CTS_temp,
			clk_baud => baud_sig,
			reset => KEY(0),
			TX_data_bit => out_bit,
			error_flag => err,
			complete_flag => complete,
			RTS => RTS_temp,
			receiver_out => output_LED
		);
	
	LEDR(17 downto 0) <= "0000000000" & output_LED;
		
end architecture;