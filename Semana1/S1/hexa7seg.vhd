----------------------------------------------------------------
-- Arquivo   : hexa7seg.vhd
-- Projeto   : Experiencia 2 - Um Fluxo de Dados Simples
----------------------------------------------------------------
-- Descricao : decodificador hexadecimal para 
--             display de 7 segmentos 
-- 
-- entrada: hexa - codigo binario de 4 bits hexadecimal
-- saida:   sseg - codigo de 7 bits para display de 7 segmentos
----------------------------------------------------------------
-- dica de uso: mapeamento para displays da placa DE0-CV
--              bit 6 mais significativo é o bit a esquerda
--              p.ex. sseg(6) -> HEX0[6] ou HEX06
----------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     29/12/2020  1.0     Edson Midorikawa  criacao
--     07/01/2023  1.1     Edson Midorikawa  revisao
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity hexa7seg is
    port (
        hexa : in  std_logic_vector(4 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end entity hexa7seg;

architecture comportamental of hexa7seg is
begin

  sseg <= "1000000" when hexa="00000" else --0
          "1111001" when hexa="00001" else --1
          "0100100" when hexa="00010" else --2
          "0110000" when hexa="00011" else --3
          "0011001" when hexa="00100" else --4
          "0010010" when hexa="00101" else --5
          "0000010" when hexa="00110" else --6
          "1111000" when hexa="00111" else --7
          "0000000" when hexa="01000" else --8
          "0000100" when hexa="01001" else --9
          "0001000" when hexa="01010" else --A
          "0000011" when hexa="01011" else --B
          "1000110" when hexa="01100" else --C
          "0100001" when hexa="01101" else --D
          "0000110" when hexa="01110" else --E
          "0001110" when hexa="01111" else --F
          "0000010" when hexa="10000" else --G
          "1001000" when hexa="10001" else --N
          "0000000" when hexa="10010" else --H
          "0000000" when hexa="10011" else --O
          "0000000" when hexa="10100" else --U
          "0000000" when hexa="10101" else --P
          "0000000" when hexa="10110" else --R
          "1110000" when hexa="11001" else --t
          "1111111";

end architecture comportamental;
