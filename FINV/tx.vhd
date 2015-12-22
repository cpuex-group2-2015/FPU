library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity transmitter is
  generic (
    wtime : std_logic_vector(15 downto 0) := x"1B16");  -- for CLK:66MHz Baudrate:9600bps
  port (  
    clk, go      : in std_logic;
    data         : in std_logic_vector(7 downto 0);
    output, busy : out std_logic);
end transmitter;

architecture structure of transmitter is 
  signal countdown : std_logic_vector(15 downto 0) := (others=>'0');
  signal outputbuf : std_logic_vector(8 downto 0) := (others=>'1');
  signal state     : std_logic_vector(3 downto 0) := "1111";

begin  -- structure
  output <= outputbuf(0);
  busy <= go when state > "1001" else '1';
  stetemachine: process (clk)
  begin  -- process stetemachine
    if rising_edge(clk) then
      if state > "1001" then
        if go = '1' then
          outputbuf <= data&'0';
          state <= "0000";
          countdown <= wtime;
        end if;
      else
        if countdown = 0 then
          outputbuf <= '1'&outputbuf(8 downto 1);
          countdown <= wtime;
          state <= state + 1;
        else
          countdown <= countdown - 1;
        end if;
      end if;
    end if;
  end process stetemachine;
end structure;
