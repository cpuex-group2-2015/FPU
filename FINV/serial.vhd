library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity serialif is
  port (
    serialO : out std_logic;
    dataIN  : in  std_logic_vector(7 downto 0);
    send    : in  std_logic;
    full    : out std_logic;    
    clk     : in  std_logic);
end serialif;

architecture structure of serialif is
  component transmitter
    generic (
      wtime : std_logic_vector(15 downto 0));
    port (
      clk, go      : in std_logic;
      data         : in std_logic_vector(7 downto 0);
      output, busy : out std_logic);
  end component;

  component fifo8
    port (
      clk   : in  std_logic;
      wr_en : in  std_logic;
      rd_en : in  std_logic;
      din   : in  std_logic_vector(7 downto 0);
      dout  : out std_logic_vector(7 downto 0);
      full  : out std_logic;
      empty : out std_logic);
  end component;
  signal filled_flag,busy : std_logic;
  signal sendData,sendDataB : std_logic_vector(7 downto 0) := (others => '1');
  signal oempty,ofull : std_logic;
  signal orden,owren,sendStart : std_logic := '0';
  signal odin,odout : std_logic_vector(7 downto 0);  
  signal sdFlag,sendStartB,ordenB : std_logic := '0';
  
  attribute box_type : string;
  attribute box_type of fifo8 : component is "black_box";
begin  -- structure
  full   <= ofull;
  owren  <= send;

  odin   <= dataIN;
  
  sdFlag <= (not oempty) and (not busy);
  sendStart <= sdFlag when sendStartB = '0' else '0';

  sendData  <= odout;

  orden   <= sdFlag when ordenB = '0' else '0';
  structure: process (clk)
  begin  -- process state
    if rising_edge(clk) then
      sendDataB  <= sendData;
      sendStartB <= sendStart;      
      ordenB     <= orden;
    end if;
  end process structure;
  txunit : transmitter 
    generic map (
      wtime  => x"1B16") -- for CLK:66MHz Baudrate:9600bps
    port map (
      clk    => clk,
      data   => sendDataB,
      go     => sendStartB,
      output => serialO,
      busy   => busy);
  obuf : fifo8
    port map (
      clk   => clk,
      wr_en => owren,
      rd_en => ordenB,
      din   => odin,
      dout  => odout,
      full  => ofull,
      empty => oempty);            
end structure;
