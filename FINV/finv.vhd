library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FINV is
  Port (
    CLK      : in  std_logic;
    input  : in  STD_LOGIC_VECTOR (31 downto 0);
    output  : out STD_LOGIC_VECTOR (31 downto 0));
end FINV;

architecture struct of FINV is
  signal a_s, a_s2, a_s3 : std_logic;
  signal a_e, a_e2, a_e3, a_e32 : std_logic_vector (7 downto 0);
  signal a0 : std_logic_vector (11 downto 0);
  signal a1, a12 : std_logic_vector (10 downto 0);
  signal data, data2, data3 : std_logic_vector (35 downto 0);
  signal grad, grad3 : std_logic_vector (23 downto 0);
  signal a_m3, grad31 : std_logic_vector (22 downto 0);

component RAM
  port(
    addr : in  STD_LOGIC_VECTOR(11 downto 0);
    do   : out STD_LOGIC_VECTOR(35 downto 0)
  );
end component;

begin

--１クロック目
  -- 符号部、指数部、仮数部をわける 
  process(CLK) begin
    if(CLK'event and CLK='1') then
      a_s <= input(31);
      a_e <= input(30 downto 23);
      a0 <= input(22 downto 11);
      a1 <= input(10 downto 0);
    end if;
  end process;

  U0 : RAM port map (a0, data); 

--２クロック目
  process(CLK) begin
    if(CLK'event and CLK='1') then
      a_s2 <= a_s;
      a_e2 <= a_e;
      data2 <= data;
      a12 <= a1;
    end if;
  end process;

  grad <= a12 * data2(12 downto 0);


--３クロック目
  process(CLK) begin
    if(CLK'event and CLK='1') then
      a_s3 <= a_s2;
      a_e3 <= a_e2;
      data3 <= data2;
      grad3 <= grad;
    end if;
  end process;

  a_e32 <= 253 - a_e3;

  grad31 <= "00000000000" & grad3(23 downto 12);

  a_m3 <= data3(35 downto 13) - grad31;

  process(CLK) begin
    if(CLK'event and CLK = '1') then
      output <= a_s3 & a_e32 & a_m3;  
    end if;
  end process;

end struct;
