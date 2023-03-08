library ieee;
use ieee.std_logic_1164.all;

entity jogo_desafio_memoria is
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
        db_jogadaIgualRodada  : out std_logic;
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
    signal uc_errou                : std_logic;
    signal uc_timeout              : std_logic;
    signal uc_pronto               : std_logic;
    signal uc_ligaLed              : std_logic;
    signal uc_df_escreveJogada     : std_logic;
	signal uc_df_resetaMemoria     : std_logic;

    --sinais que saem do DF
    signal df_uc_jogadaIgualRodada    : std_logic;
    signal df_uc_jogadaCorreta        : std_logic;
    signal df_fimCR                   : std_logic;
    signal df_fimCJ                   : std_logic;
    signal df_uc_timeout              : std_logic;
    signal df_uc_timeoutJogadaInicial : std_logic;
    signal df_uc_jogadaFeita          : std_logic;
    signal df_hex_contagem            : std_logic_vector(3 downto 0); 
    signal df_hex_memoria             : std_logic_vector(3 downto 0); 
    signal df_hex_jogada              : std_logic_vector(3 downto 0); 
    signal df_hex_rodada              : std_logic_vector(3 downto 0); 
    signal uc_hex_estado              : std_logic_vector(3 downto 0); 
    --led
    signal ligaLed : std_logic;
	 
	 signal fimDoJogo : std_logic;

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
            chaves                   : in std_logic_vector (3 downto 0); 
            jogadaIgualRodada        : out std_logic;  
            jogadaCorreta            : out std_logic; 
            fimCR                    : out std_logic; 
            fimCJ                    : out std_logic; 
            timeout                  : out std_logic; 
            timeoutJogadaInicial     : out std_logic; 
            jogada_feita             : out std_logic;  
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
            timeout              : in std_logic; 
            timeoutJogadaInicial : in std_logic;
            enderecoFinal        : in std_logic; 
            zeraCR               : out std_logic;
            zeraCJ               : out std_logic;
            contaCR              : out std_logic;
            contaCJ              : out std_logic;
            zeraT                : out std_logic; 
            zeraJogadaInicial    : out std_logic;
            zeraR                : out std_logic;
            registraR            : out std_logic; 
            acertou              : out std_logic;
            errou                : out std_logic;
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
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;
    
    component hexa7seg_modificado
        port (
            hexa : in  std_logic_vector(3 downto 0);
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
            chaves => botoes,
            jogadaIgualRodada => df_uc_jogadaIgualRodada, --saidas
            jogadaCorreta => df_uc_jogadaCorreta, 
            fimCR => df_fimCR,
            fimCJ => df_fimCJ,  
            timeout => df_uc_timeout,
            timeoutJogadaInicial => df_uc_timeoutJogadaInicial,
            jogada_feita => df_uc_jogadaFeita,
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
            zeraCR => uc_df_zeraCR, --saidas
            zeraCJ => uc_df_zeraCJ,
            contaCR => uc_df_contaCR,
            contaCJ => uc_df_contaCJ,
            zeraT => uc_df_zeraT,  
            zeraJogadaInicial => uc_df_zeraJogadaInicial,
            zeraR => uc_df_zeraR,  
            registraR => uc_df_registraR,
            acertou => uc_acertou,
            errou => uc_errou,
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
    perdeu <= uc_errou;
    pronto <= uc_pronto;
    db_timeout <= uc_timeout;
    db_jogadaIgualRodada <= df_uc_jogadaIgualRodada;
    db_jogada_correta <= df_uc_jogadaCorreta;

    HEX0: hexa7seg --contagem da rodada, contador principal
        port map (
            hexa => df_hex_contagem,
            sseg => db_contagem
        );
    
    HEX1: hexa7seg --dado que esta na memoria
        port map (
            hexa => df_hex_memoria,
            sseg => db_memoria
        );
    
    HEX2: hexa7seg --qual jogada foi feita
        port map (
            hexa => df_hex_jogada,
            sseg => db_jogadafeita
        );

    HEX3: hexa7seg --mostra o endereço atual, contador secundário
        port map (
            hexa => df_hex_rodada,
            sseg => db_rodada
        );

    HEX5: hexa7seg_modificado
        port map (
            hexa => uc_hex_estado,
            sseg => db_estado
        );
end estrutural ; -- estrutural