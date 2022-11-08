library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
entity byterec is
   port ( resetN  : in std_logic                       ;
          clk     : in std_logic                       ;
          din_new : in std_logic                       ;
          din     : in std_logic_vector(7 downto 0)    ;
          make    : out std_logic                      ;
          break   : out std_logic                      ;
          dout    : out std_logic_vector(8 downto 0) ) ;
end byterec ;

architecture arc_byterec of byterec is

   signal nor_code : std_logic ;
   signal ext_code : std_logic ;
   signal rel_code : std_logic ;
   signal ext      : std_logic ;
   signal oe       : std_logic ;
   
   -- state machine declarations
   type state is ( idle         , -- initial state
                   sample_nor   , -- sample out reg of nornal scan
                   new_make     , -- announce out new make
                   wait_rel     , -- wait for code release code
                   sample_rel   , -- sample out code of released key
                   new_break    , -- announce out new break
                   wait_ext     , -- wait for code after ext code
                   sample_ext   , -- sample out new extended code
                   wait_ext_rel ,  -- wait for code after ext-rel code
                   sample_ext_rel ) ; -- sample new extended-rel code
   signal present_state, next_state : state ;
   
begin

   -- code classifier (combinatorical)
   process ( din )
   begin
      nor_code <= '0' ;
      ext_code <= '0' ;
      rel_code <= '0' ;
      case conv_integer(din) is
         when 1 to 16#83# => nor_code <= '1' ;  -- 1 to 131
         when 16#E0#      => ext_code <= '1' ; -- 224
         when 16#F0#      => rel_code <= '1' ; -- 240
         when others      =>
      end case ;
   end process ;
   
   -- state_register
   process ( resetN , clk )
   begin
      if resetN = '0' then
         present_state <= idle ;
      elsif clk'event and clk = '1' then
         present_state <= next_state ;
      end if ;
   end process ;
   
   -- combinatorical part of state machine
   process (present_state,din_new,nor_code,ext_code,rel_code)
   begin
      -- default outputs
      make  <= '0' ;
      break <= '0' ;
      oe    <= '0' ;
      ext   <= '0' ;
      case present_state is
      
         when idle =>
            if     din_new = '1' then
               next_state <= sample_nor ;
            elsif rel_code = '1' then
               next_state <= wait_rel   ;
            elsif ext_code = '1' then
               next_state <= wait_ext   ;
            else
               next_state <= idle ;
            end if ;
            
         when sample_nor =>
            oe <= '1' ;
            next_state <= new_make ;
            
         when new_make =>
            make <= '1' ;
            next_state <= idle ;
            
         when wait_rel =>
            if din_new = '1' then
               if nor_code = '1' then
                  next_state <= sample_rel ;
               else
                  next_state <= idle ;
               end if ;
            else
               next_state <= wait_rel ;
            end if ;
            
         when sample_rel =>
            oe <= '1' ;
            next_state <= new_break ;
            
         when new_break =>
            break <= '1' ;
            next_state <= idle ;
            
         when wait_ext =>
            if din_new = '1' then
               if nor_code = '1' then
                  next_state <= sample_ext ;
               elsif rel_code = '1' then
                  next_state <= wait_ext_rel ;
               else
                  next_state <= idle ;
               end if ;
            else
               next_state <= wait_ext ;
            end if ;
         
         when sample_ext =>
            oe <= '1' ;
            ext <= '1' ;
            next_state <= new_make ;
            
         when wait_ext_rel =>
            if din_new = '1' then
               if nor_code = '1' then
                  next_state <= sample_ext_rel ;
               else
                  next_state <= idle ;
               end if ;
            else
               next_state <= wait_ext_rel ;
            end if ;
            
         when sample_ext_rel =>
            oe  <= '1' ;
            ext <= '1' ;
            next_state <= new_break ;
            
         when others =>
            next_state <= idle ;
      
      end case ;
   end process ;
   
   -- output register
   process ( resetN, clk )
   begin
      if resetN = '0' then
         dout <= (others => '0') ;
      elsif clk'event and clk = '1' then
         if oe = '1' then
            dout <= ext & din(7 downto 0) ;
         end if ;
      end if ;
   end process ;
                   
end arc_byterec ;