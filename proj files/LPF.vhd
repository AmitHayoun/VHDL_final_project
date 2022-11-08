library ieee ;
use ieee.std_logic_1164.all ;
entity LPF is
   port ( clk    : in std_logic    ;
          resetN : in std_logic    ;
          din    : in std_logic    ;
          dout   : out std_logic ) ;
end LPF ;

architecture arc_LPF of LPF is
   type state is ( LOW, L2H1, L2H2, L2H3,
                  HIGH, H2L1, H2L2, H2L3) ;
   signal present_state, next_state : state ;
   
begin

   -- State register
   process ( resetN , clk )
   begin
      if resetN = '0' then
         present_state <= LOW ;
      elsif clk'event and clk = '1' then
         present_state <= next_state ;
      end if ;
   end process ;
   
   -- Combinatorical part of state machine
   process ( present_state, din )
   begin
      dout <= '0' ;
      case present_state is
         
         when Low =>
            dout <= '0' ;
            if din = '1' then
               next_state <= L2H1 ;
            else
               next_state <= LOW ;
            end if ;
         
         when L2H1 =>
            dout <= '0' ;
            if din = '1' then
               next_state <= L2H2 ;
            else
               next_state <= LOW ;
            end if ;
            
         when L2H2 =>
            dout <= '0' ;
            if din = '1' then
               next_state <= L2H3 ;
            else
               next_state <= LOW ;
            end if ;

         when L2H3 =>
            dout <= '0' ;
            if din = '1' then
               next_state <= HIGH ;
            else
               next_state <= LOW ;
            end if ;
            
         when HIGH =>
            dout <= '1' ;
            if din = '0' then
               next_state <= H2L1 ;
            else
               next_state <= HIGH ;
            end if ;
            
         when H2L1 =>
            dout <= '1' ;
            if din = '0' then
               next_state <= H2L2 ;
            else
               next_state <= HIGH ;
            end if ;
            
         when H2L2 =>
            dout <= '1' ;
            if din = '0' then
               next_state <= H2L3 ;
            else
               next_state <= HIGH ;
            end if ;
            
         when H2L3 =>
            dout <= '1' ;
            if din = '0' then
               next_state <= LOW ;
            else
               next_state <= HIGH ;
            end if ;
            
      end case ;
   end process ;
end arc_LPF ;