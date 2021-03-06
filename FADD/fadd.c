#include <stdio.h>
#include <string.h>
#include <stdint.h>

uint32_t fadd(uint32_t a, uint32_t b)
{
   uint32_t a_s, b_s;
   uint32_t a_e, b_e;
   uint32_t a_m, b_m;
   uint32_t c_s, c_e, c_m;
   uint32_t c;
   uint32_t s;
   uint32_t w_m,l_m;
   uint32_t e_diff;
   uint32_t round=0;
   uint32_t i;
   uint32_t shift=0;

/* 符号部、指数部、仮数部をわける */
   a_s = a & 0x80000000;     //符号部
   b_s = b & 0x80000000;

   a_e = a & 0x7F800000;     //指数部
   b_e = b & 0x7F800000;

   a_m = a & 0x7FFFFF;       //仮数部
   b_m = b & 0x7FFFFF;

   a_e = (a_e >> 23);
   b_e = (b_e >> 23);

/* 指数部の差分をとりシフトを行う */

if((a == 0x0) || (a == 0x80000000))
   c = b;
else if((b == 0x0) || (b == 0x80000000))
   c = a;
else{

   if((a_e > b_e) || ((a_e == b_e) & (a_m > b_m))) {
      e_diff = a_e - b_e;
      w_m = a_m;
      l_m = b_m;
      c_e = a_e;
      c_s = a_s;
   }
   else{
      e_diff = b_e - a_e;
      w_m = b_m;
      l_m = a_m;
      c_e = b_e;
      c_s = b_s;
   }

   l_m = l_m | 0x800000;  //暗黙の１を足す
   w_m = w_m | 0x800000;

   i = e_diff;


   l_m = l_m << 2;  // guardbitの分シフト

   while(i > 0){
         round = (l_m & 0x1) | round;
         l_m = l_m >> 1;
         i--;
      }

   w_m = w_m << 3;  //guardbitとroundbitの分シフト
   l_m = (l_m << 1) | round; //roundbitを付加

/* 演算の決定および演算を行う*/

   s = a_s ^ b_s;
   if((s & 0x80000000) == 0x80000000)
      c_m = w_m - l_m;
   else
      c_m = w_m + l_m;

   
/* 丸めによって指数部に繰り上がりが発生するものを除外する */

   if(((c_m & 0x7FFFFFC) == 0x7FFFFFC) || ((c_m & 0x3FFFFFE) == 0x3FFFFFE) || ((c_m & 0x1FFFFFF) == 0x1FFFFFF)) {  //丸めで指数部に繰り上がりが生じるもの
      c_e++;
   }

   if((c_m & 0x8000000) == 0x8000000){  //仮数部の28ビット目が１
      if((c_m & 0x1) == 0x1){
         c_e++;
         c_m = (c_m >> 1) | 0x1;
      }
      else{
         c_e++;
         c_m = (c_m >> 1);
      }
   }

   while((c_m & 0x4000000) == 0x00){  //27bit目が０の間左シフト
      shift++;
      c_m = c_m << 1;
      if(shift == 27) break;
   }



   if(shift == 0 || shift == 1 || shift == 2 || shift ==3){  //丸めの処理
      if(((c_m & 4) == 4) && (((c_m & 1) == 1) || ((c_m & 2) == 2) || ((c_m & 8) == 8)))   {
         if((c_m & 0x7FFFFF8) == 0x7FFFFF8)
            c_m = 0x0;
         else
            c_m = c_m + 8;
      }
   }

   if((shift == 27) || (c_e < shift)) c_e = 0x00; 
   else c_e = c_e - shift;

   if(c_e < 0) c_e = 0x00;

   c_m = c_m >> 3;   //guardbitとroundbitの3bitを消してやる

   if((c_e == 0x0) || (c_e == 0xFF))   //無限と非正規化数の時仮数部をクリア
       c_m = 0x0;


   c_m = c_m & 0x7FFFFF;

   c_e = c_e << 23;


   c = c_s | c_e | c_m; //符号部、指数部、仮数部をくっつけて返す 

   }

   return c;
}

