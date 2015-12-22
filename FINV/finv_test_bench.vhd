LIBRARY IEEE, STD;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_textio.ALL;
USE STD.TEXTIO.ALL;

ENTITY FINV_testbench IS
END FINV_testbench;

ARCHITECTURE testbench OF FINV_testbench IS 
  -- Component Declaration for the Unit Under Test (UUT)
  COMPONENT FINV 
    port(
      CLK     : in  STD_LOGIC;
      input  : in  STD_LOGIC_VECTOR (31 downto 0);
      output : out  STD_LOGIC_VECTOR (31  downto 0)); 
  END COMPONENT;

  file inv  : text is in "/home/yamashita-takuma/CPU/finvd/a1_in.txt";
  file outv  : text is out "/home/yamashita-takuma/CPU/finvd/a_s_out.txt";

  --Inputs
  signal tb_input  : std_logic_vector(31 downto 0) := x"3f800000";
  signal tb_output :  std_logic_vector(31 downto 0);

  --Simulation
  signal simclk : std_logic := '0';
BEGIN
  unit : FINV PORT MAP (
    CLK    => simclk,
    input => tb_input,
    output => tb_output);

  this_loops_forever : process(simclk)
    variable li, lo : line;
    variable vinp_a : std_logic_vector(31 downto 0);
  begin
    if rising_edge(simclk) then
      readline(inv, li);
      read(li, vinp_a);
      tb_input <= vinp_a;
      write(lo,tb_output, LEFT,32);
      writeline(outv, lo);
    end if;
  end process; 
 
  -- generate clock for the simulation
  clockgen : process
  variable v : std_logic_vector(23 downto 0) := "000000000000000000000000";
  begin
    simclk <= '0';
    wait for 10 ns;
    simclk <= '1';
    wait for 10 ns;
    v := v + 1;
    if(v = "100000000000000000000101") then
      wait;
    end if;
  end process;
END;
