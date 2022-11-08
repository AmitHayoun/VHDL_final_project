-- [64 characters X 8 pixels X 8 pixels] X 1 = 4096 X 1 ROM table.
-- Using 1 M4K (out of 105) to implement this ROM table (LPM_ROM).
library ieee ;
use ieee.std_logic_1164.all ;
library lpm ;
use lpm.lpm_components.all ;
entity chr_state_gen8 is
   port ( clk       : in std_logic                    ;
          char_code : in std_logic_vector(5 downto 0) ; -- char code
          pospix_v  : in std_logic_vector(2 downto 0) ; -- row
          pospix_h  : in std_logic_vector(2 downto 0) ; -- col
          state     : in std_logic_vector(1 downto 0) ; -- letter state 
          red       : out std_logic					  ;
          green     : out std_logic      			  ;
          blue      : out std_logic                 ) ;
end chr_state_gen8 ;
architecture arc_chr_state_gen8 of chr_state_gen8 is
   signal internal_rom_address : std_logic_vector (11 downto 0) ;
   signal internal_rom_data    : std_logic_vector (0 downto 0)  ;
   signal dout 				   : std_logic                      ;
begin
   internal_rom_address <= char_code & pospix_v & pospix_h ;
   r1: lpm_rom
   generic map (
      lpm_widthad         => 12             , -- address width
      lpm_numwords        => 4096           , -- length = 2**widthad
      lpm_outdata         => "REGISTERED"   , -- registered outputs
      lpm_address_control => "UNREGISTERED" , -- combinatorical inputs
      lpm_file            => "CHRGEN8.MIF"  , -- ROM code file name
      lpm_width           => 1              ) -- output data width
   port map (
      address             => internal_rom_address ,
      outclock            => clk                  ,
      q                   => internal_rom_data  ) ;
   -- Convertion of std_logic_vector(0) to std_logic
   dout  <= internal_rom_data(0) 								;
   red 	 <= dout when (state = "00") or (state = "10") else '0' ;
   green <= dout when (state = "00") or (state = "11") else '0' ;
   blue  <= dout when (state = "00") or (state = "01") else '0' 					;
end arc_chr_state_gen8 ;