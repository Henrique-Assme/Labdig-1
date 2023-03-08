--------------------------------------------------------------------
-- Arquivo   : unidade_controle.vhd
-- Projeto   : Experiencia 3 - Projeto de uma unidade de controle
--------------------------------------------------------------------
-- Descricao : unidade de controle 
--
--             1) codificação VHDL (maquina de Moore)
--
--             2) definicao de valores da saida de depuracao
--                db_estado
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     20/01/2022  1.0     Edson Midorikawa  versao inicial
--     22/01/2023  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is 
    port ( 
        clock                : in std_logic;
        reset                : in std_logic;
        iniciar              : in std_logic;
        fim                  : in std_logic;
        jogada               : in std_logic;
        igual                : in std_logic;
        timeout              : in std_logic; -- sinal recebe se o tempo de fazer uma jogada já terminou ou não
        timeoutJogadaInicial : in std_logic;
        enderecoFinal        : in std_logic; -- sinal sinaliza se está na ultima rodada do ciclo atual
        zeraCR               : out std_logic;
        zeraCJ               : out std_logic;
        contaCR              : out std_logic;
        contaCJ              : out std_logic;
        zeraT                : out std_logic; --zera o timer
        zeraJogadaInicial    : out std_logic;
        zeraR                : out std_logic;
        registraR            : out std_logic; --df
        acertou              : out std_logic;
        errou                : out std_logic;
        perdeTimeout         : out std_logic;    
        pronto               : out std_logic;
        ligaLed              : out std_logic;
        escreveJogada        : out std_logic;
		resetaMemoria        : out std_logic;
        db_estado            : out std_logic_vector(3 downto 0)
    );
end entity;

architecture fsm of unidade_controle is
    type t_estado is (inicial, inicializa, mostraJogadas, espera, registra, compara, escreve, incrementaEndereco, proximaRodada, proximoDado, fimA, fimE, fimT);
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset)
    begin
        if reset='1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    Eprox <=
        inicial             when  Eatual=inicial and iniciar='0' else
        inicializa          when  Eatual=inicial and iniciar='1' else
        mostraJogadas       when  Eatual=inicializa else
        mostraJogadas       when  Eatual=mostraJogadas and timeoutJogadaInicial='0' else
        espera              when  Eatual=mostraJogadas and timeoutJogadaInicial='1' else
        espera              when  Eatual=espera and jogada='0' and timeout='0' else
        fimT                when  Eatual=espera and timeout='1' else
        registra            when  Eatual=espera and jogada='1' and timeout='0' else
        compara             when  Eatual=registra else
        proximoDado         when  Eatual=compara and igual='1' and enderecoFinal='0' and fim='0' else
        espera              when  Eatual=proximoDado else
        incrementaEndereco  when  Eatual=compara and igual='1' and enderecoFinal='1' and fim='0' else
        escreve             when  Eatual=incrementaEndereco else
		escreve             when  Eatual=escreve and timeout='0' and jogada='0' else
		fimT                when  Eatual=escreve and timeout='1' else
        proximaRodada       when  Eatual=escreve and timeout='0' and jogada='1' else
        espera              when  Eatual=proximaRodada else
        fimA                when  Eatual=compara and igual='1' and fim='1' else
        fimE                when  Eatual=compara and igual='0' else
        fimA                when  Eatual=fimA and iniciar='0' else
        fimE                when  Eatual=fimE and iniciar='0' else
        fimT                when  Eatual=fimT and iniciar='0' else
        inicializa;

    -- logica de saída (maquina de Moore)
    with Eatual select
        zeraCR <=   '1' when inicial,
                    '1' when inicializa,
                    '0' when others;
    
    with Eatual select
        zeraCJ <=   '1' when inicial,
                    '1' when inicializa,
                    '1' when proximaRodada,
                    '0' when others;

    with Eatual select
        zeraT <='1' when inicializa,
                '1' when inicial,
                '1' when proximaRodada,
                '1' when proximoDado,
                '1' when mostraJogadas
                '0' when others;
    
    with Eatual select
        zeraR <='1' when inicial,
                '1' when inicializa,
                '0' when others;
    
    with Eatual select
        registraR <='1' when registra,
                    '0' when others;

    with Eatual select
        contaCR <=  '1' when proximaRodada,
                    '0' when others;
    
    with Eatual select
        contaCJ <=  '1' when proximoDado,
					'1' when incrementaEndereco,
                    '0' when others;
    
    with Eatual select
        pronto <=   '1' when fimA,
                    '1' when fimE,
                    '1' when fimT,
                    '0' when others;
    
    with Eatual select
        errou <='1' when fimE,
                '1' when fimT,
                '0' when others;

    with Eatual select
        acertou <=  '1' when fimA,
                    '0' when others;

    with Eatual select
        perdeTimeout <= '1' when fimT,
                        '0' when others;
    
    with Eatual select
        ligaLed <= '1' when inicializa,
                   '1' when mostraJogadas,
                   '0' when others;

    with Eatual select 
        escreveJogada <='1' when escreve,
                        '0' when others;
	
	with Eatual select
		resetaMemoria <='1' when inicializa,
					    '0' when others;

    with Eatual select
        zeraJogadaInicial <='1' when inicializa,
                            '0' when others;
    
    -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "0000" when inicial,            -- 0
                     "0001" when inicializa,         -- 1
                     "0010" when mostraJogadas,      -- 2
                     "0011" when espera,             -- 3
                     "0100" when registra,           -- 4
                     "0101" when compara,            -- 5
                     "0110" when proximaRodada,      -- 6
                     "0111" when proximoDado,        -- 7
                     "1000" when escreve,            -- 8
                     "1001" when fimT,               -- 9, mostra um t no hex      
                     "1010" when fimA,               -- A
                     "1011" when incrementaEndereco, -- B  
                     "1110" when fimE,               -- E
                     "1111" when others;             -- F

end architecture fsm;
