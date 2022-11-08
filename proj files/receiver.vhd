package uart_constants_rec is

   constant clockfreq  : integer := 25000000 ;
   constant baud       : integer := 115200   ;
   constant t1_count   : integer := clockfreq / baud ; -- 217
   constant t2_count   : integer := t1_count / 2     ; -- 108

end uart_constants_rec ;

-------------------------------------------------------------------------------------

use work.uart_constants_rec.all ;
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use ieee.numeric_std.all;
entity receiver is
   port ( resetN     : in     std_logic                    ;
          clk        : in     std_logic                    ;
          rx         : in     std_logic                    ;
          read_dout  : in     std_logic                    ;
          rx_ready   : out    std_logic                    ;
          dout       : out    std_logic_vector(7 downto 0) ;
          dout_new   : out    std_logic                    ;
          dout_ready : out    std_logic                  ) ;
end receiver ;

architecture arc_receiver of receiver is

   -- input synchronization Flip-Flop
   signal rxs : std_logic ;

   -- timer            floor(log2(t1_count)) downto 0
   signal tcount : std_logic_vector(12 downto 0) ;
   signal te     : std_logic ; -- Timer_Enable/!reset
   signal t1     : std_logic ; -- end of one time slot
   signal t2     : std_logic ; -- half of one time slot

   -- data counter
   signal dcount     : std_logic_vector(2 downto 0) ; -- data counter
   signal ena_dcount : std_logic                    ; -- enable this counter
   signal clr_dcount : std_logic                    ; -- clear this counter
   signal eoc        : std_logic                    ; -- end of count (7)

   -- shift register
   signal dint      : std_logic_vector(7 downto 0) ;
   signal shift_ena : std_logic                    ; -- enable shift register

   -- output register --
   signal dout_ena : std_logic ; -- enable output register and flag

  -- state machine
   type state is
   ( idle           ,
     start_wait     ,
     start_chk      ,
     data_wait      ,
     data_chk       ,
     data_count     ,
     stop_wait      ,
     stop_chk       ,
     update_out     ,
     tell_out       ,
     break_wait   ) ;

    signal present_state , next_state : state ;

begin

   -------------------
   -- state machine --
   process (resetN,  clk)
   begin
      if resetN = '0' then
         present_state <= idle ;
      elsif rising_edge(clk) then
         present_state <= next_state ;
      end if ;
   end process ;
   
   process ( present_state, rxs, t2, t1, eoc)
   begin
      clr_dcount <= '0' ;
      rx_ready <= '0' ;
      te <= '0' ;
      shift_ena <= '0' ;
      ena_dcount <= '0' ;
      dout_ena <= '0' ;
      dout_new <= '0' ;
      
      case present_state is
         when idle =>
            clr_dcount <= '1';
            rx_ready <= '1'  ;
            if rxs = '0' then
               next_state <= start_wait ;
            else
               next_state <= idle ;
            end if ;
            
         when start_wait =>
            te <= '1' ;
            if t2 = '1' then
               next_state <= start_chk ;
            else
               next_state <= start_wait ;
            end if ;
            
         when start_chk =>
            if rxs = '0' then
               next_state <= data_wait ;
            else
               next_state <= idle ;
            end if ;
            
         when data_wait =>
            te <= '1' ;
            if t1 = '1' then
               next_state <= data_chk ;
            else
               next_state <= data_wait ;
            end if ;
            
         when data_chk =>
            shift_ena <= '1' ;
            if eoc = '0' then
               next_state <= data_count ;
            else
               next_state <= stop_wait ;
            end if ;
            
         when data_count =>
            ena_dcount <= '1' ;
            next_state <= data_wait ;
            
         when stop_wait =>
            te <= '1' ;
            if t1 = '1' then
               next_state <= stop_chk ;
            else
               next_state <= stop_wait ;
            end if ;
         
         when stop_chk =>
            if rxs = '1' then
               next_state <= update_out ;
            else
               next_state <= break_wait ;
            end if ;
            
         when update_out =>
            dout_ena <= '1' ;
            next_state <= tell_out ;
         
         when break_wait =>
            if rxs = '1' then
               next_state <= idle ;
            else
               next_state <= break_wait ;
            end if ;
            
         when tell_out =>
            dout_new <= '1' ;
            next_state <= idle ;
            
         when others => next_state <= idle ;
         
      end case ;
   end process ;
   -------------------
   
   -------------------------------------
   -- input Synchronization Flip-Flop --
   process(clk)
   begin
      if rising_edge(clk) then
         rxs <= rx ;
      end if ;
   end process ;
   -------------------------------------

   -----------
   -- timer --
   process (resetN, clk)
   begin
      if resetN = '0' then
         tcount <= (others => '0') ;
      elsif rising_edge(clk) then
         if te = '1' then
            if tcount /= t1_count then
               tcount <= tcount + 1 ;
            end if ;
         else
            tcount <= (others => '0') ;
         end if ;
      end if ;
   end process ;
   
   t1 <= '1' when (t1_count = tcount) else '0' ;
   t2 <= '1' when (t2_count = tcount) else '0' ;
   -----------

   ------------------
   -- data counter --
   process (resetN, clk)
   begin
      if resetN = '0' then
         dcount <= (others => '0') ;
      elsif rising_edge(clk) then
         if clr_dcount = '1' then
            dcount <= (others => '0') ;
         elsif ena_dcount = '1' then
            dcount <= dcount + 1 ;
         end if ;
      end if ;
   end process ;
   
   eoc <= '1' when (dcount = "111") else '0' ;
   ------------------

   --------------------
   -- internal shift register --
   process (resetN, clk)
   begin
      if resetN = '0' then
         dint <= (others => '0') ;
      elsif rising_edge(clk) then
         if shift_ena = '1' then
            dint <= rxs & dint (7 downto 1) ;
         end if ;
      end if ;
   end process ;
   --------------------

   -----------------
   -- output flag --
   process (resetN, clk)
   begin
      if rising_edge(clk) then
         if dout_ena = '1' and read_dout = '0' then
            dout_ready <= '0' ;
         elsif dout_ena = '0' and read_dout = '1' then
            dout_ready <= '1' ;
         end if ;
      end if ;
   end process ;
   -----------------
   
   ---------------------
   -- output register --
   process (resetN, clk)
   begin
      if resetN = '0' then
         dout <= "00000000" ;
      elsif rising_edge(clk) then
         if dout_ena = '1' then
            dout <= dint ;
         end if ;
      end if ;
   end process ;
   ---------------------

end arc_receiver ;

-------------------------------------------------------------------------------------
