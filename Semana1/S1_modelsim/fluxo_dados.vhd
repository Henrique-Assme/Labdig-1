--------------------------------------------------------------------
-- Arquivo   : circuito_exp2_ativ2.vhd.parcial.txt
-- Projeto   : Experiencia 2 - Um Fluxo de Dados Simples
--------------------------------------------------------------------
-- Descricao : ARQUIVO PARCIAL DO
--    Circuito do fluxo de dados da Atividade 2
--
-- COMPLETAR TRECHOS DE CODIGO ABAIXO
--
--    1) contem saidas de depuracao db_contagem e db_memoria
--    2) escolha da arquitetura do componente ram_16x4
--       para simulacao com ModelSim => ram_modelsim
--    3) escolha da arquitetura do componente ram_16x4
--       para sintese com Intel Quartus => ram_mif
--
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     11/01/2022  1.0     Edson Midorikawa  versao inicial
--     07/01/2023  1.1     Edson Midorikawa  revisao
--     10/02/2023  1.1.1   Edson Midorikawa  arquivo parcial
--------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 


entity fluxo_dados is
    port (
             clock                    : in std_logic; 
             zeraCR                   : in std_logic; 
             zeraCJ                   : in std_logic;  
             contaCR                  : in std_logic; 
             contaCJ                  : in std_logic; 
             zeraT                    : in std_logic; 
             zeraJogadaInicial        : in std_logic;
             zeraR                    : in std_logic; 
             registraR                : in std_logic; 
             escreveM                 : in std_logic; 
				     resetaMemoria            : in std_logic;
             perderVida               : in std_logic;
             chaves                   : in std_logic_vector (3 downto 0);
             jogadaIgualRodada        : out std_logic;  
             jogadaCorreta            : out std_logic; 
             fimCR                    : out std_logic; 
             fimCJ                    : out std_logic; 
             timeout                  : out std_logic; 
             timeoutJogadaInicial     : out std_logic; 
             jogada_feita             : out std_logic;
             vidaZerada               : out std_logic;
             vidas                    : out std_logic_vector (3 downto 0);
             db_contagem              : out std_logic_vector (3 downto 0); 
             db_memoria               : out std_logic_vector (3 downto 0);
             db_jogada                : out std_logic_vector (3 downto 0);
             db_rodada                : out std_logic_vector (3 downto 0);
             db_tem_jogada            : out std_logic
         );
end entity fluxo_dados;

architecture estrutural of fluxo_dados is

  --ContadorRodada
  signal s_not_zeraCR       : std_logic; 
  signal s_rodada           : std_logic_vector(3 downto 0); 
  --ContadorJogada
  signal s_not_zeraCJ       : std_logic;
  signal s_jogada           : std_logic_vector(3 downto 0);
  --registrador
  signal s_registrador      : std_logic_vector(3 downto 0);
  --memoria
  signal s_memoria          : std_logic_vector(3 downto 0);
  signal s_not_escreveM     : std_logic;
  signal conteudoEscrito    : std_logic_vector(3 downto 0);
  --edge_detector
  signal s_chaveacionada    : std_logic;
  signal reset_edge         : std_logic;
  --timer
  signal contaT             : std_logic;
  --timer
  signal contaJogadaInicial : std_logic;
  --vidas
  signal s_vidas            : std_logic_vector(3 downto 0); 

  component contador_163
    port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0);
        rco   : out std_logic 
    );
  end component;

  component comparador_85
    port (
        i_A3   : in  std_logic;
        i_B3   : in  std_logic;
        i_A2   : in  std_logic;
        i_B2   : in  std_logic;
        i_A1   : in  std_logic;
        i_B1   : in  std_logic;
        i_A0   : in  std_logic;
        i_B0   : in  std_logic;
        i_AGTB : in  std_logic;
        i_ALTB : in  std_logic;
        i_AEQB : in  std_logic;
        o_AGTB : out std_logic;
        o_ALTB : out std_logic;
        o_AEQB : out std_logic
    );
  end component;

  component ram_16x4 is
      port (
               clk          : in  std_logic;
               endereco     : in  std_logic_vector(3 downto 0);
               dado_entrada : in  std_logic_vector(3 downto 0);
               we           : in  std_logic;
               ce           : in  std_logic;
               dado_saida   : out std_logic_vector(3 downto 0)
           );
  end component;

  component registrador_n is
      generic (
          constant N: integer := 8 
      );
      port (
          clock  : in  std_logic;
          clear  : in  std_logic;
          enable : in  std_logic;
          D      : in  std_logic_vector (N-1 downto 0);
          Q      : out std_logic_vector (N-1 downto 0) 
      );
  end component;

  component edge_detector is 
      port (
          clock  : in  std_logic;
          reset  : in  std_logic;
          sinal  : in  std_logic;
          pulso  : out std_logic
      );
  end component;

  component contador_m is
      generic (
          constant M: integer := 100 -- modulo do contador
      );
      port (
          clock   : in  std_logic;
          zera_as : in  std_logic;
          zera_s  : in  std_logic;
          conta   : in  std_logic;
          Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
          fim     : out std_logic;
          meio    : out std_logic
      );
  end component;

begin

  -- sinais de controle ativos em alto
  -- sinais dos componentes ativos em baixo
  s_not_zeraCR <= not zeraCR;
  
  contadorRodada: contador_163 --esse é o contador principal que nunca é zerado
    port map (
        clock => clock,
        clr   => s_not_zeraCR,  -- clr ativo em baixo
        ld    => '1',
        ent   => '1',
        enp   => contaCR,
        D     => "0000",
        Q     => s_rodada,
        rco   => fimCR
    );

  s_not_zeraCJ <= not zeraCJ;

  contadorEndereco: contador_163 --esse é o contador que fica sendo zerado
    port map (
        clock => clock,
        clr   => s_not_zeraCJ,  -- clr ativo em baixo
        ld    => '1',
        ent   => '1',
        enp   => contaCJ,
        D     => "0000",
        Q     => s_jogada,
        rco   => fimCJ
    );

  db_contagem <= s_rodada;
  db_rodada   <= s_jogada; 

  comparadorJogadaFinal: comparador_85 
    port map (
        i_A3   => s_rodada(3),
        i_B3   => s_jogada(3),
        i_A2   => s_rodada(2),
        i_B2   => s_jogada(2),
        i_A1   => s_rodada(1),
        i_B1   => s_jogada(1),
        i_A0   => s_rodada(0),
        i_B0   => s_jogada(0),
        i_AGTB => '0',
        i_ALTB => '0',
        i_AEQB => '1',
        o_AGTB => open, -- saidas nao usadas
        o_ALTB => open,
        o_AEQB => jogadaIgualRodada
    );

  comparadorJogada: comparador_85
    port map (
        i_A3   => s_memoria(3),
        i_B3   => s_registrador(3),
        i_A2   => s_memoria(2),
        i_B2   => s_registrador(2),
        i_A1   => s_memoria(1),
        i_B1   => s_registrador(1),
        i_A0   => s_memoria(0),
        i_B0   => s_registrador(0),
        i_AGTB => '0',
        i_ALTB => '0',
        i_AEQB => '1',
        o_AGTB => open, -- saidas nao usadas
        o_ALTB => open,
        o_AEQB => jogadaCorreta
    );

  s_not_escreveM <= not escreveM;

  -- memoria: ram_16x4 (ram_mif)  -- usar esta linha para Intel Quartus
  memoria: entity work.ram_16x4 (ram_modelsim) -- usar arquitetura para ModelSim
    port map (
       clk          => clock,
       endereco     => s_jogada,
       dado_entrada => conteudoEscrito,
       we           => s_not_escreveM, -- we ativo em baixo
       ce           => '0',
       dado_saida   => s_memoria
    );

  conteudoEscrito <= chaves when resetaMemoria='0' else
                     "0001" when resetaMemoria='1';
  db_memoria      <= s_memoria;

  registrador: registrador_n
    generic map(N => 4)
    port map (
        clock => clock, 
        clear => zeraR, 
        enable => registraR,
        D => chaves,
        Q => s_registrador       
    );

  db_jogada <= s_registrador;

  s_chaveacionada <= chaves(0) or chaves(1) or chaves(2) or chaves(3);
  reset_edge      <= not s_chaveacionada;

  detetor: edge_detector
    port map(
        clock => clock,
        reset => reset_edge,
        sinal => s_chaveacionada,
        pulso => jogada_feita
    );

  db_tem_jogada <= s_chaveacionada;

  timer: contador_m
    generic map(
      --M => 5000 --testar na placa
      M => 100 --(testar no modelsim)
    )
    port map(
      clock => clock,
      zera_as => '0',
      zera_s => zeraT,
      conta => contaT,
      Q => open,
      --Q => saidaTimer_modelsim,
      fim => timeout,
      meio => open
    );

    contaT <= not zeraT;

    timerJogadaInicial: contador_m
    generic map(
      --M => 2000 --testar na placa
      M => 50 --(testar no modelsim)
    )
    port map(
      clock => clock,
      zera_as => '0',
      zera_s => zeraJogadaInicial,
      conta => contaJogadaInicial,
      Q => open,
      --Q => saidaTimer_modelsim,
      fim => timeoutJogadaInicial,
      meio => open
    );
  
    contaJogadaInicial <= not zeraJogadaInicial;
    process(perderVida, zeraCR) is
      begin
        if zeraCR='1' then
          s_vidas <= "0101";
          vidaZerada <= '0';
        elsif(perderVida = '1' and s_vidas /= "0000") then
          s_vidas <= std_logic_vector(s_vidas(3 downto 0) - "0001");
        elsif s_vidas="0001" then
          vidaZerada <= '1';
        end if;
        vidas(3 downto 0) <= s_vidas(3 downto 0);
    end process;
end architecture estrutural;

