library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity UART_Receiver is
	
	port(
		CLOCK_50			:	in std_logic;
		KEY				:	in std_logic_vector(3 downto 0);
		UART_RXD			:	in std_logic;
		UART_RTS			:	in std_logic;
		UART_TXD			:	out std_logic;
		UART_CTS			:	out std_logic;
		LEDR				:	out std_logic_vector(17 downto 0)
	);

end entity;


architecture bhv of UART_Receiver is
	
	signal baud_sig : std_logic; -- Signal for connecting baudrate generator to transmitter/receiver
	
	-- Temporary testing signals
--	signal RTS_temp	:	std_logic;
--	signal CTS_temp	:	std_logic;
--	signal out_bit		:	std_logic;
--	signal err			:	std_logic;
	signal complete	:	std_logic;
	signal CTS : std_logic;
	--signal RTS : std_logic := NOT UART_RTS;
	
	
	--signal RTS_2	:	std_logic := NOT UART_RTS;

begin

	-- Instantiation of Baud rate generator component
	baud_rate_gen	:	entity work.baud_gen(bhv)
		port map(
			clk_in => CLOCK_50,
			reset => KEY(0),
			baud_out => baud_sig
		);
	
	-- Receiver
	receiver_1	:	entity work.receiver(bhv)
		port map(
			CTS => CTS,
			clk_baud => baud_sig,
			reset => KEY(0),
			TX_data_bit => UART_RXD,
			error_flag => UART_TXD,
			complete_flag => complete,
			RTS => UART_RTS,
			receiver_out => LEDR(7 downto 0)
		);
		--LEDR(17)<= UART_RXD;
		--LEDR(16)<= not CTS;
		--LEDR(15)<= UART_RTS;
		--LEDR(14)<= UART_TXD;
		--UART_CTS <= '0';
	

end architecture;