module key1_module
(
clk,
rst,
key1,
flag
);

input clk;
input rst;
input key1;
output [3:0] flag;

 reg [3:0] flag;
 always @ (posedge clk or negedge rst )
 begin
  if(!rst)
  begin
   flag<=4'b0;
  end
  else
  if(key1 == 1)
  begin
   flag<=flag+1'b1;
   if(flag==4'b1000)
    flag<=4'b0000;
  end
 end

endmodule
