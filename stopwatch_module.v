module stopwatch_module
( clk,  RSTn3, key, HEX0, HEX1, HEX2, HEX3);  


input clk;
input RSTn3;
input key;
output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;

reg ST1;
reg [3:0] SecL = 4'd0;
reg [3:0] SecH = 4'd0;
reg [3:0] MinL = 4'd0;
reg [3:0] MinH = 4'd0;
reg  [6:0] HEX0;
reg  [6:0] HEX1;
reg  [6:0] HEX2;
reg  [6:0] HEX3;



parameter     _0 = 7'b1000000, _1 = 7'b1111001, _2 = 7'b0100100,
			 	  _3 = 7'b0110000, _4 = 7'b0011001, _5 = 7'b0010010,
			 	  _6 = 7'b0000010, _7 = 7'b1111000, _8 = 7'b0000000,
				  _9 = 7'b0010000, _10 = 7'b1111111;


				  
reg CLK = 0;
reg [24:0]Count;
parameter T1HZ = 25'd25_000_000;


always @ (posedge clk)
    begin 
	   if(Count == T1HZ - 25'b1 )
		    begin
					Count <= 0;
					CLK <= ~CLK;
				end
			else
				Count <= Count + 1;
		end				  

//module KEY1(key1, RSTn3, ST1);
always @ (negedge RSTn3  or negedge key )
    begin 
	   if (RSTn3 == 0)
		  begin
		    ST1 <= 0;
		  end
		else 
		  begin 
		    if (ST1 == 1)
			   begin
				  ST1 <= 0;
				end
			 else
			   ST1 <= 1;
			end 			
	end 


//module watchkeeping_module  
	  
	always @ ( posedge CLK  or negedge RSTn3 )
		begin
			if( !RSTn3 )
				begin 
					SecL <= 0;
					SecH <= 0;
					MinL <= 0;
					MinH <= 0;
				end
			else
				begin
                if( ST1 == 1 )
					   begin
							  SecL <= SecL;
					        SecH <= SecH;
					        MinL <= MinL;
					        MinH <= MinH;
						end
				    else
					 	begin 	  
							if( SecL == 'd9 )
						begin 
			            SecL <= 0;			
							if( SecH == 'd5 )
								begin
								   SecH <= 0;
									if( MinL == 'd9 )
										begin
											MinL <= 0;
											if( MinH == 'd5 )
												begin
													MinH <= 0;
                                    end
											else
												MinH <= MinH + 1;
										end
									else
										MinL <= MinL + 1;
								end
							else
								SecH <= SecH + 1;
						end
					else
						SecL <= SecL + 1;
				end
			end
		end	  
	  
always @ (posedge clk)
    begin 
	 
      case(SecL)	 
						'd0:  HEX0 = _0;
						'd1:  HEX0 = _1;
						'd2:  HEX0 = _2;
						'd3:  HEX0 = _3;
						'd4:  HEX0 = _4;
						'd5:  HEX0 = _5;
						'd6:  HEX0 = _6;
						'd7:  HEX0 = _7;
						'd8:  HEX0 = _8;
						'd9:  HEX0 = _9;
						'd10:  HEX0 = _10;
      endcase	
		
      case(SecH)	 
						'd0:  HEX1 = _0;
						'd1:  HEX1 = _1;
						'd2:  HEX1 = _2;
						'd3:  HEX1 = _3;
						'd4:  HEX1 = _4;
						'd5:  HEX1 = _5;
						'd6:  HEX1 = _6;
						'd7:  HEX1 = _7;
						'd8:  HEX1 = _8;
						'd9:  HEX1 = _9;
						'd10:  HEX1 = _10;
      endcase	
		
      case(MinL)	 
						'd0:  HEX2 = _0;
						'd1:  HEX2 = _1;
						'd2:  HEX2 = _2;
						'd3:  HEX2 = _3;
						'd4:  HEX2 = _4;
						'd5:  HEX2 = _5;
						'd6:  HEX2 = _6;
						'd7:  HEX2 = _7;
						'd8:  HEX2 = _8;
						'd9:  HEX2 = _9;
						'd10:  HEX2 = _10;
      endcase			
		
      case(MinH)	 
						'd0:  HEX3 = _0;
						'd1:  HEX3 = _1;
						'd2:  HEX3 = _2;
						'd3:  HEX3 = _3;
						'd4:  HEX3 = _4;
						'd5:  HEX3 = _5;
						'd6:  HEX3 = _6;
						'd7:  HEX3 = _7;
						'd8:  HEX3 = _8;
						'd9:  HEX3 = _9;
						'd10:  HEX3 = _10;
      endcase			
		
		
		 
	end
	
endmodule
