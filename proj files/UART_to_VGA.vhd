library ieee ;
use ieee.std_logic_1164.all ;
library work ;
use work.connectors.uart_to_addr ;

entity uart_to_vga is
   port ( resetN : in  std_logic                      ;
          clk    : in  std_logic                      ;
          ena    : in  std_logic                      ;
          din    : in  std_logic_vector(7 downto 0)   ;
          dout0  : out std_logic_vector(5 downto 0)   ;
          dout1  : out std_logic_vector(5 downto 0)   ;
          dout2  : out std_logic_vector(5 downto 0)   ;
          dout3  : out std_logic_vector(5 downto 0)   ;
          dout4  : out std_logic_vector(5 downto 0)   ;
          dout5  : out std_logic_vector(5 downto 0)   ;
          dout6  : out std_logic_vector(5 downto 0)   ;
          dout7  : out std_logic_vector(5 downto 0)   ;
          dout8  : out std_logic_vector(5 downto 0)   ;
          dout9  : out std_logic_vector(5 downto 0) ) ;
end uart_to_vga ;

architecture arc_uart_to_vga of uart_to_vga is

   -- component declarations 
   component reg6
      port ( resetN , clk : in  std_logic                      ;
             ena          : in  std_logic                      ;
             din          : in  std_logic_vector(5 downto 0)   ;
             dout         : out std_logic_vector(5 downto 0) ) ;
   end component ;
   
   -- actual internal signals
   signal d0_int : std_logic_vector(5 downto 0) ;
   signal d1_int : std_logic_vector(5 downto 0) ;
   signal d2_int : std_logic_vector(5 downto 0) ;
   signal d3_int : std_logic_vector(5 downto 0) ;
   signal d4_int : std_logic_vector(5 downto 0) ;
   signal d5_int : std_logic_vector(5 downto 0) ;
   signal d6_int : std_logic_vector(5 downto 0) ;
   signal d7_int : std_logic_vector(5 downto 0) ;
   signal d8_int : std_logic_vector(5 downto 0) ;
   signal d9_int : std_logic_vector(5 downto 0) ;
   
   signal din_addr : std_logic_vector(5 downto 0) ;
   
begin
	
	-- convert ascii input to address
   din_addr <= uart_to_addr(din) ;
	
   u0: reg6 port map ( resetN, clk, ena, din_addr, d0_int) ;
   u1: reg6 port map ( resetN, clk, ena, d0_int  , d1_int) ;
   u2: reg6 port map ( resetN, clk, ena, d1_int  , d2_int) ;
   u3: reg6 port map ( resetN, clk, ena, d2_int  , d3_int) ;
   u4: reg6 port map ( resetN, clk, ena, d3_int  , d4_int) ;
   u5: reg6 port map ( resetN, clk, ena, d4_int  , d5_int) ;
   u6: reg6 port map ( resetN, clk, ena, d5_int  , d6_int) ;
   u7: reg6 port map ( resetN, clk, ena, d6_int  , d7_int) ;
   u8: reg6 port map ( resetN, clk, ena, d7_int  , d8_int) ;
   u9: reg6 port map ( resetN, clk, ena, d8_int  , d9_int) ;
   
   dout9 <= d0_int ;
   dout8 <= d1_int ;
   dout7 <= d2_int ;
   dout6 <= d3_int ;
   dout5 <= d4_int ;
   dout4 <= d5_int ;
   dout3 <= d6_int ;
   dout2 <= d7_int ;
   dout1 <= d8_int ;
   dout0 <= d9_int ;
   
end arc_uart_to_vga ;