library ieee ;
use ieee.std_logic_1164.all ;

package connectors is

subtype ascii_or_ps2 is std_logic_vector(7 downto 0) ;
subtype chrgen_addr  is std_logic_vector(5 downto 0) ;

function uart_to_addr ( ascii_chr : ascii_or_ps2) return chrgen_addr ;
function ps2_to_addr  ( ps2_chr   : ascii_or_ps2) return chrgen_addr ;

end package connectors ;

package body connectors is

   function uart_to_addr ( ascii_chr : ascii_or_ps2) return chrgen_addr is
   begin
      case ascii_chr is
         when "00110000" => return("000000") ; -- 0
         when "00110001" => return("000001") ; -- 1
         when "00110010" => return("000010") ; -- 2
         when "00110011" => return("000011") ; -- 3
         when "00110100" => return("000100") ; -- 4
         when "00110101" => return("000101") ; -- 5
         when "00110110" => return("000110") ; -- 6
         when "00110111" => return("000111") ; -- 7
         when "00111000" => return("001000") ; -- 8
         when "00111001" => return("001001") ; -- 9
         when "01000001" => return("001010") ; -- A
         when "01000010" => return("001011") ; -- B
         when "01000011" => return("001100") ; -- C
         when "01000100" => return("001101") ; -- D
         when "01000101" => return("001110") ; -- E
         when "01000110" => return("001111") ; -- F
         when "01000111" => return("010000") ; -- G
         when "01001000" => return("010001") ; -- H
         when "01001001" => return("010010") ; -- I
         when "01001010" => return("010011") ; -- J
         when "01001011" => return("010100") ; -- K
         when "01001100" => return("010101") ; -- L
         when "01001101" => return("010110") ; -- M
         when "01001110" => return("010111") ; -- N
         when "01001111" => return("011000") ; -- O
         when "01010000" => return("011001") ; -- P
         when "01010001" => return("011010") ; -- Q
         when "01010010" => return("011011") ; -- R
         when "01010011" => return("011100") ; -- S
         when "01010100" => return("011101") ; -- T
         when "01010101" => return("011110") ; -- U
         when "01010110" => return("011111") ; -- V
         when "01010111" => return("100000") ; -- W
         when "01011000" => return("100001") ; -- X
         when "01011001" => return("100010") ; -- Y
         when "01011010" => return("100011") ; -- Z
         when others     => return("110000") ; -- space
      end case ;
   end ;

   function ps2_to_addr  ( ps2_chr   : ascii_or_ps2) return chrgen_addr is
   begin
       case ps2_chr is
          when "01000101" => return("000000") ; -- 0
           when "00010110" => return("000001") ; -- 1
           when "00011110" => return("000010") ; -- 2
           when "00100110" => return("000011") ; -- 3
           when "00100101" => return("000100") ; -- 4
           when "00101110" => return("000101") ; -- 5
           when "00110110" => return("000110") ; -- 6
           when "00111101" => return("000111") ; -- 7
           when "00111110" => return("001000") ; -- 8
           when "01000110" => return("001001") ; -- 9
           when "00011100" => return("001010") ; -- A
           when "00110010" => return("001011") ; -- B
           when "00100001" => return("001100") ; -- C
           when "00100011" => return("001101") ; -- D
           when "00100100" => return("001110") ; -- E
           when "00101011" => return("001111") ; -- F
           when "00110100" => return("010000") ; -- G
           when "00110011" => return("010001") ; -- H
           when "01000011" => return("010010") ; -- I
           when "00111011" => return("010011") ; -- J
           when "01000010" => return("010100") ; -- K
           when "01001011" => return("010101") ; -- L
           when "00111010" => return("010110") ; -- M
           when "00110001" => return("010111") ; -- N
           when "01000100" => return("011000") ; -- O
           when "01001101" => return("011001") ; -- P
           when "00010101" => return("011010") ; -- Q
           when "00101101" => return("011011") ; -- R
           when "00011011" => return("011100") ; -- S
           when "00101100" => return("011101") ; -- T
           when "00111100" => return("011110") ; -- U
           when "00101010" => return("011111") ; -- V
           when "00011101" => return("100000") ; -- W
           when "00100010" => return("100001") ; -- X
           when "00110101" => return("100010") ; -- Y
           when "00011010" => return("100011") ; -- Z
           when others	   => return("110000") ; -- space
      end case ;
   end ;
end package body connectors ;