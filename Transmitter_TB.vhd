library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity transmitter_tb is

end entity;

architecture bhv of transmitter_tb is

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
	
	 TYPE test_case_record IS RECORD
	  --clock, reset, start : in STD_LOGIC;  
		
		RTStest : std_logic;
		transmittedD :  std_logic_vector(7 downto 0) := "10101010"; 
		CTStest: std_logic;			
		data_bit : std_logic;
	  
   END RECORD;

   -- Define a type that is an array of the record.

   TYPE test_case_array_type IS ARRAY (0 to 15) OF test_case_record;
	
begin

	transmitter  : entity work.transmitter(bhv)
	port map(
		RTS,
		clk,
		reset,
		input,
		CTS,			
		output
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





   

     
   -- Define the array itself.  We will initialize it, one line per test vector.
   -- each line of the array is one record, and the 2 numbers in each
   -- line correspond to the 2 entries in the record.  one of these entries 
   -- represent inputs to apply, and the other represents the expected output.
	
	--(clock, reset, start, dividend, divisor, quotient, remainder)
	
   signal test_case_array : test_case_array_type := (
		("1100", "1001", "0001", "0011"),
		("1011", "0101", "0010", "0001"),
		("0101", "1000", "0000", "0101"),
		("0011", "1100", "0000", "0011"),
		("1000", "1111", "0000", "1000"),
		("0010", "1011", "0000", "0010"),
		("1010", "0101", "0010", "0000"),
		("1110", "0111", "0010", "0000"),
		("1101", "1000", "0001", "0101"),
		("1111", "0110", "0010", "0011"),
		("1001", "1101", "0000", "1001"),
		("0110", "0100", "0001", "0010"),
		("1100", "1110", "0000", "1100"),
		("0111", "1000", "0000", "0111"),
		("1011", "1110", "0000", "1011"),
		("0100", "1001", "0000", "0100")
         );             

  -- Define the digit7seg subblock, which is the component we are testing
  
     COMPONENT Division is
     Port (
	  clock, reset, start : in STD_LOGIC;
 	  dividend : in  STD_LOGIC_VECTOR (3 downto 0);     
	  divisor : in  STD_LOGIC_VECTOR (3 downto 0);   
	  quotient : out  STD_LOGIC_VECTOR (3 downto 0);    
	  remainder : out  STD_LOGIC_VECTOR (3 downto 0));   
     END COMPONENT;

   -- local signals we will use in the testbench 
	 signal clock: STD_LOGIC := '1';
	 signal reset, start : STD_LOGIC:= '0';
 	 signal dividend :  STD_LOGIC_VECTOR (3 downto 0);     
	 signal divisor :  STD_LOGIC_VECTOR (3 downto 0);   
	 signal quotient :  STD_LOGIC_VECTOR (3 downto 0);    
	 signal remainder :  STD_LOGIC_VECTOR (3 downto 0);   
		
    constant ClockFrequency : integer := 16e8; -- 100 MHz
    constant ClockPeriod    : time    := 1000 ms / ClockFrequency;

begin

   -- instantiate the design-under-test

   dut : Division PORT MAP(clock, reset, start, dividend, divisor, quotient, remainder);
	
	clock <= not clock after ClockPeriod / 2;
	
   -- Code to drive inputs and check outputs.  This is written by one process.
   -- Note there is nothing in the sensitivity list here; this means the process is
   -- executed at time 0.  It would also be restarted immediately after the process
   -- finishes, however, in this case, the process will never finish (because there is
   -- a wait statement at the end of the process).

   process
   begin      
      -- Loop through each element in our test case array.  Each element represents
      -- one test case (along with expected outputs).
      
      for i in test_case_array'low to test_case_array'high loop
		
		  -- Take the DUT to S0
		  reset <= '1';
		  start <= '0';
		  wait for 1 ns;
		  reset <= '0';
		  
		  -- Print information about the testcase to the transcript window (make sure when
        -- you run this, your transcript window is large enough to see what is happening)
        
        report "-------------------------------------------";
        report "Test case " & integer'image(i) & ":" &
                 " dividend= " & integer'image(to_integer(unsigned(test_case_array(i).dividend))) & "," &
					  " divisor= " & integer'image(to_integer(unsigned(test_case_array(i).divisor))) & ":";

        -- assign the values to the inputs of the DUT (design under test)

        dividend <= test_case_array(i).dividend; 
		  divisor <= test_case_array(i).divisor;  
		  start <= '1';		  

        -- wait for some time, to give the DUT circuit time to respond (1ns is arbitrary)                

        wait for 5 ns;
        
        -- now print the results along with the expected results
        
        report "Expected quotient= " &  
                    integer'image(to_integer(unsigned(test_case_array(i).quotient))) &
               ", Actual quotient= " &  
                    integer'image(to_integer(unsigned(quotient))) & " ," &
				   "Expected remainder= " &  
                    integer'image(to_integer(unsigned(test_case_array(i).remainder))) &
               ", Actual remainder= " &  
                    integer'image(to_integer(unsigned(remainder)));

        -- This assert statement causes a fatal error if there is a mismatch
                                                                    
        assert (unsigned(test_case_array(i).dividend) = unsigned(dividend) )
            report "MISMATCHED Dividends"
            severity failure;
		  
		  assert (unsigned(test_case_array(i).divisor) = unsigned(divisor) )
            report "MISMATCHED Divisors"
            severity failure;
	     
		  assert (unsigned(test_case_array(i).quotient) = unsigned(quotient) )
            report "MISMATCHED Quotients"
            severity failure;
		  
		  assert (unsigned(test_case_array(i).remainder) = unsigned(remainder) )
				report "MISMATCHED Remainders"
				severity failure;
				
      end loop;
                                           
      report "================== ALL TESTS PASSED =============================";
                                                                              
      wait; --- we are done.  Wait for ever
    end process;
end behavioural;