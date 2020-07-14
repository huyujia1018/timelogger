module timelogger
 (
  rst,
  clk,
  sw,
  rw,
  rs,
  en,
  data,
  //时间
  key1,key2,key3,key4,
  HEX0,HEX1,HEX2,HEX3,
  Led_out,
  Led_Out1,
  //闹钟
  RST_CLK1,RST_CLK2,
  SW2,SW3,
  HEX4,HEX5,HEX6,HEX7
 );
 
 
 input clk,rst,sw;
 input key1,key2,key3,key4;
 output rs,en,rw;
 output [7:0] data;
 output		     [6:0]		HEX0;
 output		     [6:0]		HEX1;
 output		     [6:0]		HEX2;
 output		     [6:0]		HEX3;
 output   Led_out,Led_Out1;
 
 input RST_CLK1,RST_CLK2;
 input SW2,SW3;
 output [6:0] HEX4;
 output [6:0] HEX5;
 output [6:0] HEX6;
 output [6:0] HEX7;
 
 wire key1_out,key2_out,key3_out; 
 wire [7:0] shi,fen,miao;
 wire clk,rst,sw;
 wire rs,en,rw;
 wire [7:0] data;
 wire [3:0] flag;
 
disp
 (
  rst,
  clk,
  rw,
  rs,
  en,
  data,
  key1_out,key2_out,key3_out,
    RST_CLK1,RST_CLK2,
  SW2,SW3,
  HEX4,HEX5,HEX6,HEX7,
  shi,fen,miao,
  Led_Out1
);
 
 
 stopwatch_module
( clk,  sw, key4, HEX0, HEX1, HEX2, HEX3);  

Buzzer_module
(
  clk,
  fen, miao,
  Led_out 
);
 
/*alarm_module
(
clk,
shi,
fen, 
RST_CLK1,RST_CLK2,
SW2,SW3,
HEX4,HEX5,HEX6,HEX7,
Led_Out1,
);
*/


key_pulse
(
clk,
 key1,key2,key3,
 key1_out,key2_out,key3_out
);

endmodule

 

