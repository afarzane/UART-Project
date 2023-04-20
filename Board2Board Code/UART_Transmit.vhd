library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity UART_Transmit is
	
	port(
		CLOCK_50			:	in std_logic;
		KEY				:	in std_logic_vector(3 downto 0);
		SW					:	in std_logic_vector(7 downto 0);
		UART_RXD			:	in std_logic;
		UART_RTS			:	in std_logic;
		UART_TXD			:	out std_logic;
		UART_CTS			:	out std_logic;
		LEDG				:	out std_logic_vector(0 downto 0)
	);

end entity;


architecture bhv of UART_Transmit is
	
	signal baud_sig : std_logic; -- Signal for connecting baudrate generator to transmitter/receiver
	
	-- Temporary testing signals
--	signal RTS_temp	:	std_logic;
--	signal CTS_temp	:	std_logic;
--	signal out_bit		:	std_logic;
--	signal err			:	std_logic;
--	signal complete	:	std_logic;

	signal CTS : std_logic;
	signal RTS : std_logic := UART_RTS;

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
			RTS =>  CTS,
			RX_err => UART_RXD,
			clk_baud => baud_sig,
			reset => KEY(0),
			data_packet => SW(7 downto 0),
			CTS =>  RTS,
			TX_OUT => UART_TXD
		);
--	
	UART_CTS <= CTS;
--
--	UART_TXD <= SW(1);
--	
	-- Testing only
	
	LEDG(0) <= UART_RXD;

end architecture;