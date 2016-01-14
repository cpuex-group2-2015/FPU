library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FADD is
  Port (
    CLK      : in  std_logic;
    input_a  : in  STD_LOGIC_VECTOR (31 downto 0);
    input_b  : in  STD_LOGIC_VECTOR (31 downto 0);
    output  : out STD_LOGIC_VECTOR (31 downto 0));
end FADD;

architecture struct of FADD is
  signal a_s, b_s, c_s, c_s2, c_s3, c_s31, s : std_logic;
  signal ulp, guardf, guards, round, ulp3, guardf3, guards3, round3 : std_logic;
  signal marume : std_logic;
  signal a_e, b_e, c_e, c_e2, c_e22, c_e3, c_e4, c_e5,  e_diff : std_logic_vector (7 downto 0);
  signal a_m, b_m, c_m4, c_m5, c_m6 : std_logic_vector (22 downto 0);
  signal l_mm : std_logic_vector (24 downto 0);
  signal w_m,  w_m2, l_m, l_m2 : std_logic_vector (27 downto 0);
  signal c_m, c_m2, c_m3 : std_logic_vector (27 downto 0);
  signal e_diff_5, shift, shift2,  shift3 : std_logic_vector (4 downto 0);

  component BarrelShifterRight25
    port(
      Data  : in std_logic_vector (24 downto 0);
      Shift : in std_logic_vector (4 downto 0);
      q     : out std_logic_vector (27 downto 0) 
    );
  end component;

  component BarrelShifterLeft23
    port(
      Data  : in std_logic_vector (27 downto 0);
      Shift : in std_logic_vector (4  downto 0);
      q     : out std_logic_vector (22 downto 0)
    );
  end component;


  function Leading_zero (bits : std_logic_vector (26 downto 0))
    return std_logic_vector is
    variable count : std_logic_vector (4 downto 0);
    begin
      count := "00000";
      for i in 26 downto 0 loop
        if bits(i) = '1' then
          exit;
        end if;
        count := count + 1;
      end loop;
      if count = "11011" then count := "00000";
      end if;
    return count;
  end Leading_zero;

begin

--１クロック目
  -- 符号部、指数部、仮数部をわける 
  process(CLK) begin
    if(CLK'event and CLK='1') then
      a_s <= input_a(31);
      b_s <= input_b(31);
      a_m <= input_a(22 downto 0);
      b_m <= input_b(22 downto 0);
      a_e <= input_a(30 downto 23);
      b_e <= input_b(30 downto 23);
    end if;
  end process;


 --指数部の差分をとりシフトを行う
    w_m <= "01" & a_m & "000" when ((a_e > b_e) or ((a_e = b_e) and (a_m > b_m))) 
    else   "01" & b_m & "000";

    l_mm <= "01" & b_m when ((a_e > b_e) or ((a_e = b_e) and (a_m > b_m)))
    else    "01" & a_m;

    c_e <= a_e when  ((a_e > b_e) or ((a_e = b_e) and (a_m > b_m)))
    else   b_e;

    c_s <= a_s when  ((a_e > b_e) or ((a_e = b_e) and (a_m > b_m)))
    else   b_s;

    e_diff <= a_e - b_e when ((a_e > b_e) or ((a_e = b_e) and (a_m > b_m)))
    else      b_e - a_e;

 
    e_diff_5 <= "11111" when e_diff(7 downto 5) /= "000" 
    else        e_diff(4 downto 0);
      

    U0 : BarrelShifterRight25 port map (l_mm, e_diff_5, l_m); 

--２クロック目
  process(CLK) begin
    if(CLK'event and CLK='1') then
      c_e2 <= c_e;
      w_m2 <= w_m;
      l_m2 <= l_m;
      c_s2 <= c_s;
      s <= a_s xor b_s;
    end if;
  end process;

    c_m <= w_m2 - l_m2 when s = '1' 
      else w_m2 + l_m2;

    shift <= Leading_zero(c_m(26 downto 0)); 

    c_e22 <= c_e2 + 1 when ((c_m(27) = '1') or (c_m(26 downto 2) = "1111111111111111111111111"))
        else c_e2;

    c_m2 <= '0' & c_m(27 downto 1) when ((c_m(27) = '1') and (c_m(0) = '0'))
      else  '0' & c_m(27 downto 2) & '1' when ((c_m(27) = '1') and (c_m(0) = '1'))
      else "0100000000000000000000000000" when (c_m(26 downto 2) = "1111111111111111111111111")
      else c_m;

    shift2 <= "00000" when (c_m(27) = '1')
         else shift;    

    ulp <= c_m2(3) when ((shift2(1) = '0') and (shift2(0) = '0'))
      else c_m2(2) when ((shift2(1) = '0') and (shift2(0) = '1'))
      else c_m2(1) when ((shift2(1) = '1') and (shift2(0) = '0'))
      else c_m2(0) when ((shift2(1) = '1') and (shift2(0) = '1'))
      else '0';

    guardf <= c_m2(2) when ((shift2(1) = '0') and (shift2(0) = '0'))
      else c_m2(1) when ((shift2(1) = '0') and (shift2(0) = '1'))
      else c_m2(0) when ((shift2(1) = '1') and (shift2(0) = '0'))
      else '0';

    guards <= c_m2(1) when ((shift2(1) = '0') and (shift2(0) = '0'))
        else c_m2(0) when ((shift2(1) = '0') and (shift2(0) = '1'))
        else '0';

    round <= c_m2(0) when ((shift2(1) = '0') and (shift2(0) = '0'))
        else '0';

--３クロック目
  process(CLK) begin
    if(CLK'event and CLK='1') then
      c_e3 <= c_e22;
      c_s3 <= c_s2;
      shift3 <= shift2;
      c_m3  <= c_m2;
      ulp3 <= ulp;
      guardf3 <= guardf;
      guards3 <= guards;
      round3 <= round;
    end if;
  end process;

  marume <= '1' when ((shift3(4 downto 2) = "000") and (guardf3 = '1') and ((ulp3 = '1') or (guards3 = '1') or (round3 = '1')))
       else '0';

  c_e4 <= c_e3 - shift3;

  c_e5 <= "00000000" when (c_e3 < shift3)
     else c_e4;

  U1 : BarrelShifterLeft23 port map(c_m3, shift3, c_m4);

  c_m5 <= c_m4 + 1 when marume = '1'
           else c_m4;

  c_m6 <= "00000000000000000000000" when ((c_e5 = "00000000") or (c_e5 = "11111111"))     else c_m5;

  c_s31 <= '0' when (c_e5 = "00000000")
      else c_s3;

  process(CLK) begin
    if(CLK'event and CLK = '1') then
      output <= c_s31 & c_e5 & c_m6;  
    end if;
  end process;

end struct;

