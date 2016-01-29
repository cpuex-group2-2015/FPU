#include <stdio.h>
#include <string.h>
#include <stdint.h>

uint32_t fmul(uint32_t a, uint32_t b)
{
   uint32_t a_s, b_s;
   uint32_t a_e, b_e;
   uint32_t a_m, b_m;
   uint32_t c_s, c_e, c_m;
   uint32_t a_h, b_h, a_l, b_l;
   uint32_t hh, hl, lh;
   uint32_t c;

/* 符号部、指数部、仮数部をわける */
   a_s = a & 0x80000000;     //符号部
   b_s = b & 0x80000000;

   a_e = a & 0x7F800000;     //指数部
   b_e = b & 0x7F800000;

   a_m = a & 0x7FFFFF;       //仮数部
   b_m = b & 0x7FFFFF;

   a_e = (a_e >> 23);
   b_e = (b_e >> 23);

/* 符号部をxor */
   c_s = a_s ^ b_s;

/* 指数部の計算 */
   c_e = a_e + b_e;


/* 上位ビットと下位ビットにわけて計算 */
   a_h = 0x800000 | (a_m & 0x7FF800);

   b_h = 0x800000 | (b_m & 0x7FF800);

   a_h = a_h >> 11;

   b_h = b_h >> 11;

   a_l = a_m & 0x7FF;

   b_l = b_m & 0x7FF;

   hh = a_h * b_h;

   hl = a_h * b_l;

   lh = a_l * b_h;

   hl = hl >> 11;

   lh = lh >> 11;

   c_m = hh + hl + lh + 2;


/* 繰り上がりがあるかの判定 */
   if((c_m & 0x2000000) == 0x2000000)
      c_e = c_e + 1;

/* ８ビット目と９ビット目が０の時は０にする */
   if((c_e & 0x180) == 0x0)
      c_e = 0x0;
   else
      c_e = c_e - 127;

/* ９ビット目が１の時はMAXにする */
   if((c_e & 0x100) == 0x100)
      c_e = 0xFF;

/* 繰り上がりがあるかないかで使う適用するマンティッサを選ぶ */
   if((c_m & 0x2000000) == 0x0)
      {c_m = (c_m & 0xFFFFFE);
       c_m = c_m >> 1;}
   else
      {c_m = (c_m & 0x1FFFFFC);   
       c_m = c_m >> 2;}

   if(((c_e & 0xFF) == 0xFF) || ((c_e & 0xFF) == 0x0))
      c_m = 0x0;

   if((c_e & 0xFF) == 0x0)
      c_s = 0x0;

   c_m = c_m & 0x7FFFFF;

   c_e = c_e << 23;


   c = c_s | c_e | c_m; //符号部、指数部、仮数部をくっつけて返す

   return c;
}

