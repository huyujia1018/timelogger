module alarm_module
(
clk,
shi,
fen, 
RST_CLK1,RST_CLK2,
SW2,SW3,
HEX4,HEX5,HEX6,HEX7,
Led_Out1,
);

input clk;
input RST_CLK1,RST_CLK2;
input SW2,SW3;
input shi,fen;
output [6:0] HEX4;
output [6:0] HEX5;
output [6:0] HEX6;
output [6:0] HEX7;
output Led_Out1;
reg [3:0] HourL = 4'd0;
reg [3:0] HourH = 4'd0;
reg [3:0] MinL = 4'd0;
reg [3:0] MinH = 4'd0;
reg  [6:0] HEX4;
reg  [6:0] HEX5;
reg  [6:0] HEX6;
reg  [6:0] HEX7;



//闹钟跑表
 parameter     _0 = 7'b1000000, _1 = 7'b1111001, _2 = 7'b0100100,
			 	  _3 = 7'b0110000, _4 = 7'b0011001, _5 = 7'b0010010,
			 	  _6 = 7'b0000010, _7 = 7'b1111000, _8 = 7'b0000000,
				  _9 = 7'b0010000, _10 = 7'b1111111;


//标准秒时钟				  
reg CLK_1HZ = 0;
reg [24:0]Count;
parameter T1HZ = 25'd25_000_000;


always @ (posedge clk)
    begin 
	   if(Count == T1HZ - 25'b1 )
		    begin
					Count <= 0;
					CLK_1HZ <= ~CLK_1HZ;
				end
			else
				Count <= Count + 1;
		end				  



//闹钟定时（两路跑步为原型）
	  
	always @ ( posedge CLK_1HZ  or negedge RST_CLK1 )
		begin
			if( !RST_CLK1 )
				begin 
					MinL <= 0;
					MinH <= 0;
				end
			else
				begin
                if( SW2 == 1 )
					   begin
							  MinL <= MinL;
					        MinH <= MinH;
						end
				    else
					 	begin 	  
							if( MinL == 'd9 )
								begin 
								MinL <= 0;			
								if( MinH == 'd5 )
										MinH <= 0;
								else
									MinH <= MinH + 1;
								end
							else
								MinL <= MinL + 1;
						end
				end
			
		end

		
			always @ ( posedge CLK_1HZ  or negedge RST_CLK2 )
		begin
			if( !RST_CLK2 )
				begin 
					HourL <= 0;
					HourH <= 0;
				end
			else
				begin
                if( SW3 == 1 )
					   begin
							  HourL <= HourL;
					        HourH <= HourH;
						end
				    else
					 	begin 	  
							if( HourL == 'd9 )
								begin
								HourL <= 0;			
								HourH <= HourH + 1;
								end
							else if(HourL == 'd3 && HourH == 'd2)
								begin
								HourL <= 0;
								HourH <= 0;
								end
							else
								HourL <= HourL + 1;
						end
				end
			
		end
			
		

//闹钟比较
		



wire [7:0] FEN;
wire [7:0] SHI;	
reg Led_Out1;	
assign FEN = MinL +MinH*10;
assign SHI = HourL +HourH*10;
always @ (posedge clk)
    begin 
	   if ( (FEN == fen) && (SHI == shi) )
		Led_Out1 <= 1;
		else  
		  Led_Out1 <= 0;
	 end
 
	 
		  

//闹钟定时的数码管显示	  
always @ (posedge clk)
    begin 
	 
      case(MinL)	 
						'd0:  HEX4 = _0;
						'd1:  HEX4 = _1;
						'd2:  HEX4 = _2;
						'd3:  HEX4 = _3;
						'd4:  HEX4 = _4;
						'd5:  HEX4 = _5;
						'd6:  HEX4 = _6;
						'd7:  HEX4 = _7;
						'd8:  HEX4 = _8;
						'd9:  HEX4 = _9;
						'd10:  HEX4 = _10;
      endcase	
		
      case(MinH)	 
						'd0:  HEX5 = _0;
						'd1:  HEX5 = _1;
						'd2:  HEX5 = _2;
						'd3:  HEX5 = _3;
						'd4:  HEX5 = _4;
						'd5:  HEX5 = _5;
						'd6:  HEX5 = _6;
						'd7:  HEX5 = _7;
						'd8:  HEX5 = _8;
						'd9:  HEX5 = _9;
						'd10:  HEX5 = _10;
      endcase	
		
      case(HourL)	 
						'd0:  HEX6 = _0;
						'd1:  HEX6 = _1;
						'd2:  HEX6 = _2;
						'd3:  HEX6 = _3;
						'd4:  HEX6 = _4;
						'd5:  HEX6 = _5;
						'd6:  HEX6 = _6;
						'd7:  HEX6 = _7;
						'd8:  HEX6 = _8;
						'd9:  HEX6 = _9;
						'd10:  HEX6 = _10;
      endcase			
		
      case(HourH)	 
						'd0:  HEX7 = _0;
						'd1:  HEX7 = _1;
						'd2:  HEX7 = _2;
						'd3:  HEX7 = _3;
						'd4:  HEX7 = _4;
						'd5:  HEX7 = _5;
						'd6:  HEX7 = _6;
						'd7:  HEX7 = _7;
						'd8:  HEX7 = _8;
						'd9:  HEX7 = _9;
						'd10:  HEX7 = _10;
      endcase			
		
	 end
endmodule
