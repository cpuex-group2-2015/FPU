LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

library UNISIM;
use UNISIM.VComponents.all;

ENTITY FINV_top IS
  port ( MCLK1 : in STD_LOGIC;
         RS_TX : out STD_LOGIc);
END FINV_top;

ARCHITECTURE top OF FINV_top IS 
  -- Component Declaration for the Unit Under Test (UUT)
  COMPONENT FINV 
    Port (
      CLK     : in  STD_LOGIC;
      input  : in  STD_LOGIC_VECTOR (31 downto 0);
      output  : out STD_LOGIC_VECTOR (31 downto 0));
  END COMPONENT;


  COMPONENT serialif 
    port (
      serialO : out std_logic;
      dataIN  : in  std_logic_vector(7 downto 0);
      send    : in  std_logic;
      full    : out std_logic;
      clk     : in  std_logic);
  END COMPONENT;

  type rom_t is array(0 to 7) of std_logic_vector(31 downto 0); 
  signal rom_addr : std_logic_vector(2 downto 0) := (others => '0');
  signal clk,iclk: std_logic;
  signal uart_send: std_logic := '0';
  signal uart_full: std_logic := '0';
  signal inp: std_logic_vector (31 downto 0);
  signal answer: std_logic_vector (7 downto 0);
  signal added : std_logic_vector (31 downto 0);
  signal added_a : std_logic_vector (31 downto 0);
  constant data1 : rom_t := ( "10110111100100111000001110010001",
                              "01001110001100101111001110011000",
                              "01000000101111010000001000100110",
                              "11101001000000010101010011001011",
                              "01101000100010010010110100000010",
                              "11101000100001000000000000110111",
                              "10110101001010100001011101111101",
                              "11001001111101101100101000101001");


  constant added_rom : rom_t := ( "11000111010111100010001010001110",
                                  "00110000101101110001110001101110",
                                  "00111110001011010101111000110100",
                                  "10010101111111010101110101101010",
                                  "00010110011011101110000000111101",
                                  "10010110011110000011110110101001",
                                  "11001001110000001010011000100001",
                                  "10110101000001001100011011101101");



BEGIN
  ib: IBUFG port map (
    i=>MCLK1,
    o=>iclk);
  bg: BUFG port map (
    i=>iclk,
    o=>clk);

  finverse: FINV 
    port map (
      CLK   =>clk,
      input=>inp,
      output=>added);


  serial: serialif --generic map (wtime =>x"1ADB")
    port map (
      serialO=>RS_TX,
      dataIN=>answer,
      send=>uart_send,
      full=>uart_full,
      clk=>clk);

  rom_if : process(clk)
  begin
    if rising_edge(clk) then
      inp <= data1(conv_integer(rom_addr));
      added_a <= added_rom(conv_integer(rom_addr));
    end if;
  end process;

  comp : process(clk)
  begin
    if rising_edge(clk) then
      if added = added_a then
        answer <= x"84";
      else
        answer <= x"70";
      end if;
    end if;
  end process;

  send_meg : process(clk)
  begin
    if rising_edge(clk) then
      if uart_full='0' and uart_send='0' then
         uart_send<='1';
         rom_addr <= rom_addr+1;
      else
        uart_send<='0';
      end if;
    end if;
  end process;
end top; 
       
