LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_textio.all;
use std.textio.all;

library UNISIM;
use UNISIM.VComponents.all;

ENTITY RAM IS
  port ( 
         addr : in  STD_LOGIC_VECTOR(11 downto 0);
         do   : out STD_LOGIc_VECTOR(35 downto 0));
END RAM;


architecture behavior of RAM is
   
   subtype rom_data_t is std_logic_vector(35 downto 0);
   type rom_t is array (0 to 4095) of rom_data_t;
   
   impure function init_rom(filename: string)
     return rom_t is
     file f : text open read_mode is filename;
     variable tmp : std_logic_vector(35 downto 0);
     variable l : line;
     variable rom : rom_t;
     begin
       for i in rom'range loop
         if not endfile(f) then
           readline(f, l);
           read(l, tmp);
           rom(i) := tmp;
         end if;
       end loop;
   
     return rom;
   end init_rom;
   
   signal ram: rom_t := init_rom("/home/yamashita-takuma/CPU/finvd/table.txt");

   begin
   
   do <= ram(conv_integer(addr));
   
end behavior;
