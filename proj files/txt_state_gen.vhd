library ieee ;
use ieee.std_logic_1164.all ;
use ieee. std_logic_unsigned.all ;
library work ;
use work.connectors.ps2_to_addr ;

entity txt_state_gen is
   port ( clk       : in 	 std_logic                      ;
          resetN    : in     std_logic						;
          count_v   : in 	 std_logic_vector(9 downto 0)   ;
          count_h   : in 	 std_logic_vector(9 downto 0)   ;
          din0		: in 	 std_logic_vector(5 downto 0)	;
          din1		: in 	 std_logic_vector(5 downto 0)	;
          din2		: in 	 std_logic_vector(5 downto 0)	;
          din3		: in 	 std_logic_vector(5 downto 0)	;
          din4		: in 	 std_logic_vector(5 downto 0)	;
          din5		: in  	 std_logic_vector(5 downto 0)	;
          din6		: in  	 std_logic_vector(5 downto 0)	;
          din7		: in  	 std_logic_vector(5 downto 0)	;
          din8		: in  	 std_logic_vector(5 downto 0)	;
          din9		: in     std_logic_vector(5 downto 0)	;
          new_chr   : in     std_logic						;
          kbd_chr   : in     std_logic_vector(7 downto 0)   ;
          char_code : buffer std_logic_vector(5 downto 0)   ;
          pospix_v  : buffer std_logic_vector(2 downto 0)   ;
          pospix_h  : buffer std_logic_vector(2 downto 0)   ;
          state     : out    std_logic_vector(1 downto 0)   ; 
          success   : out    std_logic					  ) ;
end txt_state_gen ;
architecture arc_txt_state_gen of txt_state_gen is
   -- internal outputs (to be synchronized)
   signal int_char_code : std_logic_vector (5 downto 0) ;
   signal int_pospix_h  : std_logic_vector (2 downto 0) ; -- 3 bit/8 pix
   signal int_pospix_v  : std_logic_vector (2 downto 0) ; -- 3 bit/8 pix
   signal int_poschr_h  : std_logic_vector (5 downto 0) ; -- 7 bit/max 80
   signal int_poschr_v  : std_logic_vector (5 downto 0) ; -- 7 bit/max 60
   
   signal int_state     : std_logic_vector (1 downto 0) ; -- state for current letter 
   signal int_state0    : std_logic_vector (1 downto 0) ; -- state for din0 letter
   signal int_state1    : std_logic_vector (1 downto 0) ; -- state for din1 letter
   signal int_state2    : std_logic_vector (1 downto 0) ; -- state for din2 letter
   signal int_state3    : std_logic_vector (1 downto 0) ; -- state for din3 letter
   signal int_state4    : std_logic_vector (1 downto 0) ; -- state for din4 letter
   signal int_state5    : std_logic_vector (1 downto 0) ; -- state for din5 letter
   signal int_state6    : std_logic_vector (1 downto 0) ; -- state for din6 letter
   signal int_state7    : std_logic_vector (1 downto 0) ; -- state for din7 letter
   signal int_state8    : std_logic_vector (1 downto 0) ; -- state for din8 letter
   signal int_state9    : std_logic_vector (1 downto 0) ; -- state for din9 letter
   
   signal kbd_addr : std_logic_vector(5 downto 0) ;
   
   type state1 is 
   ( idle   ,
     check0 ,
     wrong0 ,
     check1 ,
     wrong1 ,
     check2 ,
     wrong2 ,
     check3 ,
     wrong3 ,
     check4 ,
     wrong4 ,
     check5 ,
     wrong5 ,
     check6 ,
     wrong6 ,
     check7 ,
     wrong7 ,
     check8 ,
     wrong8 ,
     check9 ,
     wrong9 ,
     done ) ;
     
	signal present_state, next_state : state1 ;
    
begin

   -- keyboard button to address
   kbd_addr <= ps2_to_addr(kbd_chr) ;

   -- state register
   process( clk , resetN )
   begin
	 if resetN = '0' then
		 present_state <= check0 ;
	 elsif clk'event and clk = '1' then
		 present_state <= next_state ;
	 end if ;
   end process ;
   
   -- combinatorical part of state machine
   process( present_state, kbd_addr, new_chr, din0, din1, din2, din3, din4, din5, din6, din7, din8, din9 )
   begin
	 -- default outputs
	 int_state0 <= "00" ;
	 int_state1 <= "00" ;
	 int_state2 <= "00" ;
	 int_state3 <= "00" ;
	 int_state4 <= "00" ;
	 int_state5 <= "00" ;
	 int_state6 <= "00" ;
	 int_state7 <= "00" ;
	 int_state8 <= "00" ;
	 int_state9 <= "00" ;
	 success	<= '0'  ;

	 case present_state is
	 
		when check0 =>
			int_state0 <= "01" ;
			if din0 = "110000" then
				next_state <= done ;
			elsif new_chr = '1' then
				if kbd_addr = din0 then
					next_state <= check1 ;
				else
					next_state <= wrong0 ;
				end if ;
			else
				next_state <= check0 ;
			end if ;
			
		when wrong0 =>
			int_state0 <= "10" ;
			if kbd_addr = din0 then
				next_state <= check1 ;
			else
				next_state <= wrong0 ;
			end if ;
			
		when check1 =>
			int_state0 <= "11" ;
			int_state1 <= "01" ;
			if din1 = "110000" then
				next_state <= done ;
			elsif new_chr = '1' then
				if kbd_addr = din1 then
					next_state <= check2 ;
				else
					next_state <= wrong1 ;
				end if ;
			else
				next_state <= check1 ;
			end if ;
			
		when wrong1 =>
			int_state0 <= "11" ;
			int_state1 <= "10" ;
			if kbd_addr = din1 then
				next_state <= check2 ;
			else
				next_state <= wrong1 ;
			end if ;
			
		when check2 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "01" ;
			if din2 = "110000" then
				next_state <= done ;
			elsif new_chr = '1' then
				if kbd_addr = din2 then
					next_state <= check3 ;
				else
					next_state <= wrong2 ;
				end if ;
			else
				next_state <= check2 ;
			end if ;
		
		when wrong2 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "10" ;
			if kbd_addr = din2 then
				next_state <= check3 ;
			else
				next_state <= wrong2 ;
			end if ;
			
		when check3 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "01" ;
			if din3 = "110000" then
				next_state <= done ;
			elsif new_chr = '1' then
				if kbd_addr = din3 then
					next_state <= check4 ;
				else
					next_state <= wrong3 ;
				end if ;
			else
				next_state <= check3 ;
			end if ;
			
		when wrong3 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "10" ;
			if kbd_addr = din3 then
				next_state <= check4 ;
			else
				next_state <= wrong3 ;
			end if ;
			
		when check4 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "01" ;
			if din4 = "110000" then
				next_state <= done ;
			elsif new_chr = '1' then
				if kbd_addr = din4 then
					next_state <= check5 ;
				else
					next_state <= wrong4 ;
				end if ;
			else
				next_state <= check4 ;
			end if ;
				
		when wrong4 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "10" ;
			if kbd_addr = din4 then
				next_state <= check5 ;
			else
				next_state <= wrong4 ;
			end if ;
			
		when check5 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "01" ;
			if din5 = "110000" then
				next_state <= done ;
			elsif new_chr = '1' then
				if kbd_addr = din5 then
					next_state <= check6 ;
				else
					next_state <= wrong5 ;
				end if ;
			else
				next_state <= check5 ;
			end if ;
				
		when wrong5 => 
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "10" ;
			if kbd_addr = din5 then
				next_state <= check6 ;
			else
				next_state <= wrong5 ;
			end if ;
			
		when check6 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "11" ;
			int_state6 <= "01" ;
			if din6 = "110000" then
				next_state <= done ;
			elsif new_chr = '1' then
				if kbd_addr = din6 then
					next_state <= check7 ;
				else
					next_state <= wrong6 ;
				end if ;
			else
				next_state <= check6 ;
			end if ;
			
		when wrong6 => 
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "11" ;
			int_state6 <= "10" ;
			if kbd_addr = din6 then
				next_state <= check7 ;
			else
				next_state <= wrong6 ;
			end if ;
			
		when check7 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "11" ;
			int_state6 <= "11" ;
			int_state7 <= "01" ;
			if din7 = "110000" then
				next_state <= done ;
			elsif new_chr = '1' then
				if kbd_addr = din7 then
					next_state <= check8 ;
				else
					next_state <= wrong7 ;
				end if ;
			else
				next_state <= check7 ;
			end if ;
			
		when wrong7 => 
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "11" ;
			int_state6 <= "11" ;
			int_state7 <= "10" ;
			if kbd_addr = din7 then
				next_state <= check8 ;
			else
				next_state <= wrong7 ;
			end if ;
			
		when check8 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "11" ;
			int_state6 <= "11" ;
			int_state7 <= "11" ;
			int_state8 <= "01" ;
			if din8 = "110000" then
				next_state <= done ;
			elsif new_chr = '1' then
				if kbd_addr = din8 then
					next_state <= check9 ;
				else
					next_state <= wrong8 ;
				end if ;
			else
				next_state <= check8 ;
			end if ;
			
		when wrong8 => 
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "11" ;
			int_state6 <= "11" ;
			int_state7 <= "11" ;
			int_state8 <= "10" ;
			if kbd_addr = din8 then
				next_state <= check9 ;
			else
				next_state <= wrong8 ;
			end if ;
			
		when check9 =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "11" ;
			int_state6 <= "11" ;
			int_state7 <= "11" ;
			int_state8 <= "11" ;
			int_state9 <= "01" ;
			if din9 = "110000" then
				next_state <= done ;
			elsif new_chr = '1' then
				if kbd_addr = din9 then
					next_state <= done ;
				else
					next_state <= wrong9 ;
				end if ;
			else
				next_state <= check9 ;
			end if ;
				
		when wrong9 => 
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "11" ;
			int_state6 <= "11" ;
			int_state7 <= "11" ;
			int_state8 <= "11" ;
			int_state9 <= "10" ;
			if kbd_addr = din9 then
				next_state <= done ;
			else
				next_state <= wrong9 ;
			end if ;
			
		when done =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "11" ;
			int_state6 <= "11" ;
			int_state7 <= "11" ;
			int_state8 <= "11" ;
			int_state9 <= "11" ;
			success    <= '1'  ;
			next_state <= idle ;
			
		when idle =>
			int_state0 <= "11" ;
			int_state1 <= "11" ;
			int_state2 <= "11" ;
			int_state3 <= "11" ;
			int_state4 <= "11" ;
			int_state5 <= "11" ;
			int_state6 <= "11" ;
			int_state7 <= "11" ;
			int_state8 <= "11" ;
			int_state9 <= "11" ;
			next_state <= idle ;
		
		when others =>	-- bad state recovery
			next_state <= check0 ;
		
	end case ;
   end process ;
   
   -- Low bits are column of pixel in char box
   int_pospix_h <= count_h(3 downto 1) ;
   -- High bits are column of text on screen
   int_poschr_h <= count_h(9 downto 4) ;
   -- Low bits are row of pixel in char box
   int_pospix_v <= count_v(3 downto 1) ;
   -- High bits are row of text on screen
   int_poschr_v <= count_v(9 downto 4) ;
   
   -- Text generation process
   process (int_poschr_h, int_poschr_v, din0, int_state0, din1, int_state1, din2, int_state2, din3, int_state3, din4,
			int_state4  ,   din5, int_state5, din6, int_state6, din7, int_state7, din8, int_state8, din9, int_state9)
   begin
	  if din0 = "110000" then -- if the software app dont runing or empty word
	     case conv_integer(int_poschr_v) is
			 when 14 => -- line 14
				case conv_integer(int_poschr_h) is
				   when 8      => int_state <= "00" ; int_char_code <= "011001" ; -- P
				   when 9      => int_state <= "00" ; int_char_code <= "010101" ; -- L
				   when 10     => int_state <= "00" ; int_char_code <= "001110" ; -- E
				   when 11     => int_state <= "00" ; int_char_code <= "001010" ; -- A
				   when 12     => int_state <= "00" ; int_char_code <= "011100" ; -- S
				   when 13     => int_state <= "00" ; int_char_code <= "001110" ; -- E
				   when 14     => int_state <= "00" ; int_char_code <= "110000" ; -- space
				   when 15     => int_state <= "00" ; int_char_code <= "011011" ; -- R
				   when 16     => int_state <= "00" ; int_char_code <= "011110" ; -- U
				   when 17     => int_state <= "00" ; int_char_code <= "010111" ; -- N
				   when 18     => int_state <= "00" ; int_char_code <= "110000" ; -- space
				   when 19     => int_state <= "00" ; int_char_code <= "011101" ; -- T
				   when 20     => int_state <= "00" ; int_char_code <= "010001" ; -- H
				   when 21     => int_state <= "00" ; int_char_code <= "001110" ; -- E
				   when 22     => int_state <= "00" ; int_char_code <= "110000" ; -- space
				   when 23     => int_state <= "00" ; int_char_code <= "011100" ; -- S
				   when 24     => int_state <= "00" ; int_char_code <= "011000" ; -- O
				   when 25     => int_state <= "00" ; int_char_code <= "001111" ; -- F
				   when 26     => int_state <= "00" ; int_char_code <= "011101" ; -- T
				   when 27     => int_state <= "00" ; int_char_code <= "100000" ; -- W
				   when 28     => int_state <= "00" ; int_char_code <= "001010" ; -- A
				   when 29     => int_state <= "00" ; int_char_code <= "011011" ; -- R
				   when 30     => int_state <= "00" ; int_char_code <= "001110" ; -- E				   
				   when others => int_state <= "00" ; int_char_code <= "110000" ; -- space
			    end case ;
			 when others       => int_state <= "00" ; int_char_code <= "110000" ; -- space
		 end case ;
	
	  elsif din0 = "100000" and din1 = "010010" and -- if get 'WIN ' from uart 
		 din2 = "010111" and din3 = "110000" then
		 case conv_integer (int_poschr_v) is
			 when 15 => -- line 15
				case conv_integer(int_poschr_h) is
				   when 18     => int_state <= "11" ; int_char_code <= "100000" ; -- W
				   when 19     => int_state <= "11" ; int_char_code <= "010010" ; -- I
				   when 20     => int_state <= "11" ; int_char_code <= "010111" ; -- N
				   when 21     => int_state <= "11" ; int_char_code <= "010111" ; -- N
				   when 22     => int_state <= "11" ; int_char_code <= "001110" ; -- E
				   when 23     => int_state <= "11" ; int_char_code <= "011011" ; -- R
				   when others => int_state <= "00" ; int_char_code <= "110000" ; -- space
			    end case ;
			 when others       => int_state <= "00" ; int_char_code <= "110000" ; -- space
		 end case ;
		 
	  else
		  case conv_integer(int_poschr_v) is
			 when 14 => -- line 14
				case conv_integer(int_poschr_h) is
				   when 6      => int_state <= "00" ; int_char_code <= "011001" ; -- P
				   when 7      => int_state <= "00" ; int_char_code <= "010101" ; -- L
				   when 8      => int_state <= "00" ; int_char_code <= "001110" ; -- E
				   when 9      => int_state <= "00" ; int_char_code <= "001010" ; -- A
				   when 10     => int_state <= "00" ; int_char_code <= "011100" ; -- S
				   when 11     => int_state <= "00" ; int_char_code <= "001110" ; -- E
				   when 12     => int_state <= "00" ; int_char_code <= "110000" ; -- space
				   when 13     => int_state <= "00" ; int_char_code <= "011101" ; -- T
				   when 14     => int_state <= "00" ; int_char_code <= "100010" ; -- Y
				   when 15     => int_state <= "00" ; int_char_code <= "011001" ; -- P
				   when 16     => int_state <= "00" ; int_char_code <= "001110" ; -- E
				   when 17     => int_state <= "00" ; int_char_code <= "110000" ; -- space
				   when 18     => int_state <= "00" ; int_char_code <= "011101" ; -- T
				   when 19     => int_state <= "00" ; int_char_code <= "010001" ; -- H
				   when 20     => int_state <= "00" ; int_char_code <= "001110" ; -- E
				   when 21     => int_state <= "00" ; int_char_code <= "110000" ; -- space
				   when 22     => int_state <= "00" ; int_char_code <= "100000" ; -- W
				   when 23     => int_state <= "00" ; int_char_code <= "011000" ; -- O
				   when 24     => int_state <= "00" ; int_char_code <= "011011" ; -- R
				   when 25     => int_state <= "00" ; int_char_code <= "001101" ; -- D
				   when 26     => int_state <= "00" ; int_char_code <= "110000" ; -- space
				   when 27     => int_state <= "00" ; int_char_code <= "001011" ; -- B
				   when 28     => int_state <= "00" ; int_char_code <= "001110" ; -- E
				   when 29     => int_state <= "00" ; int_char_code <= "010101" ; -- L
				   when 30     => int_state <= "00" ; int_char_code <= "011000" ; -- O
				   when 31     => int_state <= "00" ; int_char_code <= "100000" ; -- W
				   when others => int_state <= "00" ; int_char_code <= "110000" ; -- space
				end case ;
			 
			 when 16 => -- line 16
				case conv_integer(int_poschr_h) is
				   when 15     => int_state <= int_state0 ; int_char_code <= din0  	; -- first   letter
				   when 16     => int_state <= int_state1 ; int_char_code <= din1  	; -- second  letter
				   when 17     => int_state <= int_state2 ; int_char_code <= din2  	; -- third   letter
				   when 18     => int_state <= int_state3 ; int_char_code <= din3  	; -- fourth  letter
				   when 19     => int_state <= int_state4 ; int_char_code <= din4  	; -- fifth   letter
				   when 20     => int_state <= int_state5 ; int_char_code <= din5  	; -- sixth   letter
				   when 21     => int_state <= int_state6 ; int_char_code <= din6  	; -- seventh letter
				   when 22     => int_state <= int_state7 ; int_char_code <= din7  	; -- eigth   letter
				   when 23     => int_state <= int_state8 ; int_char_code <= din8  	; -- ninth   letter
				   when 24     => int_state <= int_state9 ; int_char_code <= din9 	; -- thenth  letter
				   when others => int_state <= "00" 	; int_char_code <= "110000" ; -- space
				end case ;
				
			 when others 	   => int_state <= "00"     ; int_char_code <= "110000" ; -- space
		  end case ;
	  end if ;
   end process ;
   
   -- Pipeline (synchronization) stage
   process (clk)
   begin
      if clk'event and clk = '1' then
         char_code <= int_char_code ;
         pospix_v  <= int_pospix_v  ;
         pospix_h  <= int_pospix_h  ;
         state 	   <= int_state     ;
      end if ;
   end process ;
      
end arc_txt_state_gen ;