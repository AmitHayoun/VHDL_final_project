library ieee ;
use ieee.std_logic_1164.all ;
entity reg8 is
   port ( resetN , clk : in std_logic                      ;
          ena          : in std_logic                      ;
          din          : in std_logic_vector(7 downto 0)   ;
          dout         : out std_logic_vector(7 downto 0) ) ;
end reg8 ;
architecture arc_reg8 of reg8 is
begin
   process( resetN , clk )
   begin
      if resetN = '0' then
         dout <= (others => '0') ;
      elsif clk'event and clk = '1' then
         if ena = '1' then
            dout <= din ;
         end if ;
      end if ;
   end process ;
end arc_reg8 ;
   