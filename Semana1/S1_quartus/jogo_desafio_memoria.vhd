library ieee;
use ieee.std_logic_1164.all;

entity jogo_desafio_memoria is
    port (
        clock                   : in  std_logic;
        reset                   : in  std_logic;
        iniciar                 : in  std_logic;
        continuar               : in  std_logic;
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
        db_vidas                : out std_logic_vector (6 downto 0);
        db_jogadaIgualRodada    : out std_logic;
        db_jogada_correta       : out std_logic;
        db_timeout              : out std_logic
    );
end entity;

architecture estrutural of jogo_desafio_memoria is
    --sinais que saem da UC
    signal uc_df_zeraCR            : std_logic; 
    signal uc_df_zeraCJ            : std_logic;
    signal uc_df_contaCR           : std_logic;
    signal uc_df_contaCJ           : std_logic;
    signal uc_df_zeraT             : std_logic;
    signal uc_df_zeraJogadaInicial : std_logic;
    signal uc_df_zeraR             : std_logic;
    signal uc_df_registraR         : std_logic;
    signal uc_acertou              : std_logic;
    signal uc_timeout              : std_logic;
    signal uc_pronto               : std_logic;
    signal uc_ligaLed              : std_logic;
    signal uc_df_escreveJogada     : std_logic;
	signal uc_df_resetaMemoria     : std_logic;
    signal uc_df_errou             : std_logic;
    signal uc_df_perderVida        : std_logic;

    --sinais que saem do DF
    signal df_uc_jogadaIgualRodada    : std_logic;
    signal df_uc_jogadaCorreta        : std_logic;
    signal df_fimCR                   : std_logic;
    signal df_fimCJ                   : std_logic;
    signal df_uc_timeout              : std_logic;
    signal df_uc_timeoutJogadaInicial : std_logic;
    signal df_uc_jogadaFeita          : std_logic;
    signal df_uc_vidaZerada           : std_logic;
    signal df_hex_contagem            : std_logic_vector(3 downto 0); 
    signal df_hex_memoria             : std_logic_vector(3 downto 0); 
    signal df_hex_jogada              : std_logic_vector(3 downto 0); 
    signal df_hex_rodada              : std_logic_vector(3 downto 0); 
    signal uc_hex_estado              : std_logic_vector(3 downto 0);
    signal df_hex_vidas                   : std_logic_vector(3 downto 0);
    --led
    signal ligaLed : std_logic;
	--auxiliares
	signal fimDoJogo : std_logic;
    signal tipo      : std_logic_vector(1 downto 0);
    --hexa7seg
    signal entradaHEX0 : std_logic_vector(4 downto 0);
    signal saidaHEX0   : std_logic_vector(6 downto 0);
    signal entradaHEX1 : std_logic_vector(4 downto 0);
    signal saidaHEX1   : std_logic_vector(6 downto 0);
    signal entradaHEX2 : std_logic_vector(4 downto 0);
    signal saidaHEX2   : std_logic_vector(6 downto 0);
    signal entradaHEX3 : std_logic_vector(4 downto 0);
    signal saidaHEX3   : std_logic_vector(6 downto 0);
    signal entradaHEX4 : std_logic_vector(4 downto 0);
    signal saidaHEX4   : std_logic_vector(6 downto 0);
    signal entradaHEX5 : std_logic_vector(4 downto 0);
    signal saidaHEX5   : std_logic_vector(6 downto 0);

    component fluxo_dados
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
    end component;

    component unidade_controle
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
            continuar            : in std_logic; -- sinal que quando 1, vai para o estado de perder uma vida
            vidaZerada           : in std_logic;
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
            perderVida           : out std_logic;
            perdeTimeout         : out std_logic;    
            pronto               : out std_logic;
            ligaLed              : out std_logic;
            escreveJogada        : out std_logic;
            resetaMemoria        : out std_logic;
            db_estado            : out std_logic_vector(3 downto 0)
            );
    end component;

    component hexa7seg
        port (
            hexa : in  std_logic_vector(4 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

begin

    fluxoDados: fluxo_dados
        port map (
            clock  => clock,
            zeraCR => uc_df_zeraCR,
            zeraCJ => uc_df_zeraCJ,   
            contaCR => uc_df_contaCR,
            contaCJ => uc_df_contaCJ,     
            zeraT => uc_df_zeraT,
            zeraJogadaInicial => uc_df_zeraJogadaInicial,
            zeraR => uc_df_zeraR,
            registraR => uc_df_registraR, 
            escreveM => uc_df_escreveJogada,    
            resetaMemoria => uc_df_resetaMemoria,    
            perderVida => uc_df_perderVida,                  
            chaves => botoes,
            jogadaIgualRodada => df_uc_jogadaIgualRodada, --saidas
            jogadaCorreta => df_uc_jogadaCorreta, 
            fimCR => df_fimCR,
            fimCJ => df_fimCJ,  
            timeout => df_uc_timeout,
            timeoutJogadaInicial => df_uc_timeoutJogadaInicial,
            jogada_feita => df_uc_jogadaFeita,
            vidaZerada => df_uc_vidaZerada,
            vidas => df_hex_vidas,
            db_contagem => df_hex_contagem,       
            db_memoria => df_hex_memoria,       
            db_jogada => df_hex_jogada,
            db_rodada => df_hex_rodada,
            db_tem_jogada => open  
        );               

	 fimDoJogo <= df_fimCR and df_fimCJ;

    unidadeControle: unidade_controle
        port map (
            clock => clock,    
            reset => reset,
            iniciar => iniciar,
            fim => fimDoJogo,
            jogada => df_uc_jogadaFeita,
            igual => df_uc_jogadaCorreta,
            timeout => df_uc_timeout,
            timeoutJogadaInicial => df_uc_timeoutJogadaInicial,
            enderecoFinal => df_uc_jogadaIgualRodada,
            continuar => continuar,
            vidaZerada => df_uc_vidaZerada,
            zeraCR => uc_df_zeraCR, --saidas
            zeraCJ => uc_df_zeraCJ,
            contaCR => uc_df_contaCR,
            contaCJ => uc_df_contaCJ,
            zeraT => uc_df_zeraT,  
            zeraJogadaInicial => uc_df_zeraJogadaInicial,
            zeraR => uc_df_zeraR,  
            registraR => uc_df_registraR,
            acertou => uc_acertou,
            errou => uc_df_errou,
            perderVida => uc_df_perderVida,
            perdeTimeout => uc_timeout,
            pronto => uc_pronto,  
            ligaLed => uc_ligaLed, 
            escreveJogada => uc_df_escreveJogada,
			resetaMemoria => uc_df_resetaMemoria,
            db_estado => uc_hex_estado
        );

    with uc_ligaLed select
        leds <= "0001" when '1',
                botoes when others;
    
    ganhou <= uc_acertou;
    perdeu <= uc_df_errou;
    pronto <= uc_pronto;
    db_timeout <= uc_timeout;
    db_jogadaIgualRodada <= df_uc_jogadaIgualRodada;
    db_jogada_correta <= df_uc_jogadaCorreta;

    tipo <= "00" when uc_acertou='1' and uc_df_errou='0' else
            "01" when uc_acertou='0' and uc_df_errou='1' and uc_timeout='0' else
            "10" when uc_acertou='0' and uc_df_errou='1' and uc_timeout='1' else
            "11";

    with tipo select
        entradaHEX0 <= "10000" when "00", --G
                       "10101" when "01", --P
                       "0" & df_hex_contagem when others;
    with tipo select
        entradaHEX1 <= "01010" when "00", --A
                       "01110" when "01", --E
                       "0" & df_hex_memoria when others;
    with tipo select
        entradaHEX2 <= "10001" when "00", --N
                       "10110" when "01", --R
                       "0" & df_hex_jogada when others;
    with tipo select
        entradaHEX3 <= "10010" when "00", --H
                       "01101" when "01", --D
                       "0" & df_hex_rodada when others;
    with tipo select
        entradaHEX4 <= "10011" when "00", --O
                       "01110" when "01", --E
                       "0" & df_hex_vidas when others;
    with tipo select
        entradaHEX5 <= "10100" when "00", --U
                       "10100" when "01", --U
                       "11001" when "10", --t
                       "0" & uc_hex_estado when others;                   

    db_contagem <= saidaHEX0;
    db_memoria <= saidaHEX1;
    db_jogadafeita <= saidaHEX2;
    db_rodada <= saidaHEX3;
    db_vidas <= saidaHEX4;
    db_estado <= saidaHEX5;

    
    HEX0: hexa7seg --contagem da rodada, contador principal
        port map (
            hexa => entradaHEX0,
            sseg => saidaHEX0
        );
    
    HEX1: hexa7seg --dado que esta na memoria
        port map (
            hexa => entradaHEX1,
            sseg => saidaHEX1
        );
    
    HEX2: hexa7seg --qual jogada foi feita
        port map (
            hexa => entradaHEX2,
            sseg => saidaHEX2
        );

    HEX3: hexa7seg --mostra o endereço atual, contador secundário
        port map (
            hexa => entradaHEX3,
            sseg => saidaHEX3
        );

    HEX4: hexa7seg --vidas
        port map (
            hexa => entradaHEX4,
            sseg => saidaHEX4
        );

    HEX5: hexa7seg --estado
        port map (
            hexa => entradaHEX5,
            sseg => saidaHEX5
        );
end estrutural ; -- estrutural