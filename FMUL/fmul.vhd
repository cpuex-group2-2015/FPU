library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FMUL is
  Port (
    CLK      : in  std_logic;
    input_a  : in  STD_LOGIC_VECTOR (31 downto 0);
    input_b  : in  STD_LOGIC_VECTOR (31 downto 0);
    output  : out STD_LOGIC_VECTOR (31 downto 0));
end FMUL;

architecture struct of FMUL is
  signal a_s, b_s, c_s, c_s2, c_s3, c_s31 : std_logic;
  signal a_e, b_e, c_e34 : std_logic_vector (7 downto 0);
  signal c_e, c_e2, c_e_a2, c_e_b2, c_e_a3, c_e_b3, c_e31, c_e32, c_e33  : std_logic_vector (8 downto 0);
  signal a_m, b_m, c_m32, c_m33 : std_logic_vector (22 downto 0);
  signal a_h, b_h : std_logic_vector (12 downto 0);
  signal a_l, b_l : std_logic_vector (10 downto 0);
  signal c_m2, c_m31, hh, hl, lh, hh2, hl2, lh2, hls, lhs : std_logic_vector (25 downto 0);


begin

--１クロック目
  -- 符号部、指数部、仮数部をわける 
  process(CLK) begin
    if(CLK'event and CLK='1') then
      a_s <= input_a(31);
      b_s <= input_b(31);
      a_e <= input_a(30 downto 23);
      b_e <= input_b(30 downto 23);
      a_m <= input_a(22 downto 0);
      b_m <= input_b(22 downto 0);
    end if;
  end process;


 --仮数部を上位12bitと下位11bitにわけてそれぞれ計算する
    c_s <= a_s xor b_s;

    c_e <= ('0' & a_e) + ('0' & b_e);

    a_h <= '1' & a_m(22 downto 11); 

    b_h <= '1' & b_m(22 downto 11);

    a_l <= a_m(10 downto 0); 

    b_l <= b_m(10 downto 0);

    hh <= a_h * b_h; 
  
    hl <= a_h * ("00" & b_l);

    lh <= ("00" & a_l) *  b_h;

--２クロック目
  process(CLK) begin
    if(CLK'event and CLK='1') then
      c_s2 <= c_s;
      c_e2 <= c_e;
      hh2 <= hh;
      hl2 <= hl;
      lh2 <= lh;
    end if;
  end process;

  hls <= "00000000000" & hl2(25 downto 11);

  lhs <= "00000000000" & lh2(25 downto 11);
  

  c_m2 <= hh2 + hls + lhs + 2;

  c_e_a2 <= c_e2;

  c_e_b2 <= c_e2 + 1;



--３クロック目
  process(CLK) begin
    if(CLK'event and CLK='1') then
      c_s3 <= c_s2;
      c_e_a3 <= c_e_a2;
      c_e_b3 <= c_e_b2;
      c_m31 <= c_m2;
    end if;
  end process;

  c_e31 <= c_e_a3 when (c_m31(25) = '0')
     else c_e_b3;

  c_e32 <= "000000000" when ((c_e31(8) = '0') and (c_e31(7) = '0')) ---下の非正規化数
      else c_e31 -127;

  c_e33 <= "111111111" when (c_e32(8) = '1')  ---上の非正規化数
      else c_e32;

  c_e34 <= c_e33(7 downto 0);

  c_m32 <= c_m31(23 downto 1) when (c_m31(25) = '0')
      else c_m31(24 downto 2);  

  c_m33 <= "00000000000000000000000" when ((c_e34 = "11111111") or (c_e34 = "00000000"))
      else c_m32;

  c_s31 <= '0' when (c_e34 = "00000000")
      else c_s3;


  process(CLK) begin
    if(CLK'event and CLK = '1') then
      output <= c_s31 & c_e34 & c_m33;  
    end if;
  end process;

end struct;

