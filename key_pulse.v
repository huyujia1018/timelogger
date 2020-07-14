module key_pulse
(
clk,
 key1,key2,key3,
 key1_out,key2_out,key3_out
);

 input clk;
 input key1,key2,key3;
 output key1_out,key2_out,key3_out;
 
 reg key1_out,key2_out,key3_out,key4_out;

 //=============key1，key2,key3,key4 下降沿脉冲================//
reg key1_reg1,key1_reg2;
reg key2_reg1,key2_reg2;
reg key3_reg1,key3_reg2;
reg [31:0] count;
always @(posedge clk)
begin
 count<=count+1;
  if(count==500000)
  begin
   count<=0;
   key1_reg1<=key1;
   key2_reg1<=key2;
   key3_reg1<=key3;
  end
  key1_reg2<=key1_reg1;
  key2_reg2<=key2_reg1;
  key3_reg2<=key3_reg1;
  
  key1_out <= key1_reg2 & (!key1_reg1);//当按下key瞬间，key_out为1
  key2_out <= key2_reg2 & (!key2_reg1);
  key3_out <= key3_reg2 & (!key3_reg1);

 end
endmodule