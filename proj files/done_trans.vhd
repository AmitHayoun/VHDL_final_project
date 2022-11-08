library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use ieee.numeric_std.all;

entity done_trans is
   port ( clk    : in  std_logic                      ;
          resetN : in  std_logic                      ;
          start  : in  std_logic                      ;
          wr_din : out std_logic                      ;
          dout   : out std_logic_vector(7 downto 0) ) ;
end done_trans ;

architecture arc_done_trans of done_trans is

   signal counter : std_logic_vector(11 downto 0) ;
   signal ena	  : std_logic					 ;
   signal clr	  : std_logic					 ;
   signal eoc	  : std_logic					 ;
   signal moc : std_logic ; 

   type state2 is ( idle               ,
                   first_letter        , -- S
                   second_letter       , -- U
                   third_letter        , -- C
                   fourth_letter       , -- C
                   fifth_letter        , -- E
                   sixth_letter        , -- S
                   seventh_letter    ) ; -- S
                   
   signal present_state, next_state : state2 ;
   
begin
      
   -- state register
   process( clk , resetN )
   begin
      if resetN = '0' then
         present_state <= idle       ;
      elsif clk'event and clk = '1' then
         present_state <= next_state ;
      end if ;
   end process ;
   
   -- combinatorical part of state machine
   process ( present_state, start, moc, eoc )
   begin
      wr_din <= '0'      ;
      dout <= "00000000" ;
      ena <= '0' ;
      clr <= '0' ;
      case present_state is
         
         when idle =>
            if start = '1' then
               next_state <= first_letter ;
            else
               next_state <= idle   	  ;
            end if ;
            
         when first_letter => 
			dout       <= "01010011"     ; -- S
            ena <= '1'					 ;
            if moc = '1' then
				wr_din     <= '1'            ;
				next_state <= first_letter   ;
            elsif eoc = '1' then
				next_state <= second_letter  ;
				clr <= '1' ;
			else
				next_state <= first_letter ;
			end if ;
            
         when second_letter => 
            dout       <= "01010101"     ; -- U
            ena <= '1'					 ;
            if moc = '1' then
				wr_din     <= '1'            ;
				next_state <= second_letter   ;
            elsif eoc = '1' then
				next_state <= third_letter  ;
				clr <= '1' ;
			else
				next_state <= second_letter ;
			end if ;
            
         when third_letter => 
            dout       <= "01000011"     ; -- C
            ena <= '1'					 ;
            if moc = '1' then
				wr_din     <= '1'            ;
				next_state <= third_letter   ;
            elsif eoc = '1' then
				next_state <= fourth_letter  ;
				clr <= '1' ;
			else
				next_state <= third_letter ;
			end if ;
            
         when fourth_letter => 
            dout       <= "01000011"     ; -- C
            ena <= '1'					 ;
            if moc = '1' then
				wr_din     <= '1'            ;
				next_state <= fourth_letter   ;
            elsif eoc = '1' then
				next_state <= fifth_letter  ;
				clr <= '1' ;
			else
				next_state <= fourth_letter ;
			end if ;
            
         when fifth_letter => 
            dout       <= "01000101"     ; -- E
            ena <= '1'					 ;
            if moc = '1' then
				wr_din     <= '1'            ;
				next_state <= fifth_letter   ;
            elsif eoc = '1' then
				next_state <= sixth_letter  ;
				clr <= '1' ;
			else
				next_state <= fifth_letter ;
			end if ;
            
         when sixth_letter => 
            dout <= "01010011"			; -- S
            ena <= '1'					 ;
            if moc = '1' then
				wr_din     <= '1'            ;
				next_state <= sixth_letter   ;
            elsif eoc = '1' then
				next_state <= seventh_letter  ;
				clr <= '1' ;
			else
				next_state <= sixth_letter ;
			end if ;
            
         when seventh_letter => 
            dout       <= "01010011"    ; -- S
            ena <= '1'					 ;
            if moc = '1' then
				wr_din     <= '1'            ;
				next_state <= seventh_letter   ;
            elsif eoc = '1' then
				next_state <= idle  ;
				clr <= '1' ;
			else
				next_state <= seventh_letter ;
			end if ;
			
		 when others         =>
			next_state <= idle ;
         
      end case ;
   end process ;
   
   process (resetN, clk)
   begin
      if resetN = '0' then
         counter <= (others => '0') ;
      elsif rising_edge(clk) then
         if clr = '1' then
            counter <= (others => '0') ;
         elsif ena = '1' then
            counter <= counter + 1 ;
         end if ;
      end if ;
   end process ;
   
   eoc <= '1' when (counter = "111111111110") else '0' ;
   moc <= '1' when (counter = "011111111110") else '0' ;
   
end arc_done_trans ;