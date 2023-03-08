--------------------------------------------------------------------------
-- Arquivo   : circuito_exp4_tb_modelo.vhd
-- Projeto   : Experiencia 04 - Desenvolvimento de Projeto de
--                              Circuitos Digitais com FPGA
--------------------------------------------------------------------------
-- Descricao : modelo de testbench para simulação com ModelSim
--
--             implementa um Cenário de Teste do circuito
--             com 4 jogadas certas e erro na quinta jogada
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     01/02/2020  1.0     Edson Midorikawa  criacao
--     27/01/2021  1.1     Edson Midorikawa  revisao
--     27/01/2022  1.2     Edson Midorikawa  revisao e adaptacao
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

-- entidade do testbench
entity jogo_desafio_memoria_tb_perdeu_timeout is
end entity;

architecture tb of jogo_desafio_memoria_tb_perdeu_timeout is

  -- Componente a ser testado (Device Under Test -- DUT)
  component jogo_desafio_memoria
    port (
      clock                   : in  std_logic;
      reset                   : in  std_logic;
      iniciar                 : in  std_logic;
      botoes                  : in  std_logic_vector (3 downto 0);
      leds                    : out std_logic_vector (3 downto 0);
      pronto                  : out std_logic;
      ganhou                  : out std_logic;
      perdeu                  : out std_logic;
      db_contagem             : out std_logic_vector (6 downto 0);
      db_memoria              : out std_logic_vector (6 downto 0);
      db_rodada               : out std_logic_vector (6 downto 0);
      db_estado               : out std_logic_vector (6 downto 0);
      db_jogadafeita          : out std_logic_vector (6 downto 0);
      db_jogadaIgualRodada    : out std_logic;
      db_jogada_correta       : out std_logic;
      db_timeout              : out std_logic
    );
  end component;
  
  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in     : std_logic := '0';
  signal rst_in     : std_logic := '0';
  signal iniciar_in : std_logic := '0';
  signal botoes_in  : std_logic_vector(3 downto 0) := "0000";

  ---- Declaracao dos sinais de saida
  signal leds_out                          : std_logic_vector(3 downto 0) := "0000";
  signal ganhou_out                        : std_logic := '0';
  signal perdeu_out                        : std_logic := '0';
  signal pronto_out                        : std_logic := '0';
  signal contagem_out                      : std_logic_vector(6 downto 0) := "0000000";
  signal memoria_out                       : std_logic_vector(6 downto 0) := "0000000";
  signal rodada_out                        : std_logic_vector(6 downto 0) := "0000000";
  signal estado_out                        : std_logic_vector(6 downto 0) := "0000000";
  signal jogada_feita_out                  : std_logic_vector(6 downto 0) := "0000000";
  signal jogadaIgualRodada_out             : std_logic := '0';
  signal jogada_correta_out                : std_logic := '0';
  signal timeout_out                       : std_logic := '0';

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- frequencia 50MHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- DUT para Simulacao
  dut: jogo_desafio_memoria
       port map
       (
          clock                  => clk_in,
          reset                  => rst_in,
          iniciar                => iniciar_in,
          botoes                 => botoes_in,
          ganhou                 => ganhou_out,
          perdeu                 => perdeu_out,
          pronto                 => pronto_out,
          leds                   => leds_out,
          db_contagem            => contagem_out,      
          db_memoria             => memoria_out,
          db_rodada              => rodada_out,
          db_estado              => estado_out,
          db_jogadafeita         => jogada_feita_out,
          db_jogadaIgualRodada   => jogadaIgualRodada_out,
          db_jogada_correta      => jogada_correta_out,
          db_timeout             => timeout_out
       );
 
  ---- Gera sinais de estimulo para a simulacao
  -- Cenario de Teste : acerta as primeiras 4 jogadas
  --                    e erra a 5a jogada
  stimulus: process is
  begin

    -- inicio da simulacao
    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    -- gera pulso de reset (1 periodo de clock)
    rst_in <= '1';
    wait for clockPeriod;
    rst_in <= '0';

    -- pulso do sinal de Iniciar (muda na borda de descida do clock)
    wait until falling_edge(clk_in);
    iniciar_in <= '1';
    wait until falling_edge(clk_in);
    iniciar_in <= '0';
    wait for 50*clockPeriod;
    
    -- espera para inicio dos testes
    wait for 10*clockPeriod;
    wait until falling_edge(clk_in);

    -- Cenario de Teste - acerta todas as jogadas

    ---- jogada #1 (chaves=0001 e 10 clocks de duracao)
    botoes_in <= "0001";
    wait for 10*clockPeriod;
    botoes_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;  

    ---- escreve #1 (chaves=0010 e 5 clocks de duracao)
    botoes_in <= "0010";
    wait for 5*clockPeriod;
    botoes_in <= "0000";
    -- espera entre jogadas de 5 clocks
    wait for 5*clockPeriod;

    ---- jogada #1 (chaves=0001 e 10 clocks de duracao)
    botoes_in <= "0001";
    wait for 10*clockPeriod;
    botoes_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;

    ---- jogada #2 (chaves=0010 e 10 clocks de duracao)
    botoes_in <= "0010";
    wait for 10*clockPeriod;
    botoes_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;
    
    ---- escreve #2 (chaves=0100 e 5 clocks de duracao)
    botoes_in <= "0100";
    wait for 5*clockPeriod;
    botoes_in <= "0000";
    -- espera entre jogadas de 5 clocks
    wait for 5*clockPeriod;

    ---- jogada #1 (chaves=0001 e 10 clocks de duracao)
    botoes_in <= "0001";
    wait for 10*clockPeriod;
    botoes_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;

    ---- jogada #2 (chaves=0010 e 10 clocks de duracao)
    botoes_in <= "0010";
    wait for 10*clockPeriod;
    botoes_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 101*clockPeriod; 

    ---- final do testbench
    assert false report "fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: processo aguarda indefinidamente
  end process;


end architecture;
