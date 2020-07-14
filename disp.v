module disp
 (
  rst,
  clk,
  rw,
  rs,
  en,
  data,
  key1,key2,key3,
  RST_CLK1,RST_CLK2,
  SW2,SW3,
  HEX4,HEX5,HEX6,HEX7,
  shi,fen,miao,
  Led_Out1
 );
 
 input clk,rst;
 input key1,key2,key3;
 output rs,en,rw;
 output [7:0] data;
 output [7:0] shi,fen,miao;
 
 input RST_CLK1,RST_CLK2;
input SW2,SW3;
output [6:0] HEX4;
output [6:0] HEX5;
output [6:0] HEX6;
output [6:0] HEX7;
reg [3:0] HourL = 4'd0;
reg [3:0] HourH = 4'd0;
reg [3:0] MinL = 4'd0;
reg [3:0] MinH = 4'd0;
reg  [6:0] HEX4;
reg  [6:0] HEX5;
reg  [6:0] HEX6;
reg  [6:0] HEX7;
 
 
 
 
 
 
 
 reg rs,en_sel;
 reg [7:0] data;
 reg [14:0] year;
 reg [7:0] shi,fen,miao,month,dat;
 reg [31:0]count,count1;  //LCD CLK 分频计数器
 reg lcd_clk;
 //2行32个数据寄存器
 reg [7:0] one_1,one_2,one_3,one_4,one_5,one_6,one_7,one_8,one_9,one_10,one_11,one_12,one_13,one_14,one_15,one_16;
 reg [7:0] two_1,two_2,two_3,two_4,two_5,two_6,two_7,two_8,two_9,two_10,two_11,two_12,two_13,two_14,two_15,two_16;
 reg [7:0] next;
 parameter state0  =8'h00,     //设置8位格式,2行,5*7    8'h38;
    state1  =8'h01,  //整体显示,关光标,不闪烁  8'h0C    闪烁 8'h0e
    state2  =8'h02,  //设定输入方式,增量不移位 8'h06
    state3  =8'h03,  //清除显示     8'h01
    state4  =8'h04,  //显示第一行的指令  80H
    state5  =8'h05,  //显示第二行的指令  80H+40H
    
    scan =8'h06,  
    nul  =8'h07; 
 
 parameter data0  =8'h10,  //2行32个数据状态
    data1  =8'h11,
    data2  =8'h12,
    data3  =8'h13,
    data4  =8'h14,
    data5  =8'h15,
    data6  =8'h16,
    data7  =8'h17,
    data8  =8'h18,
    data9  =8'h19,
    data10  =8'h20,
    data11  =8'h21,
    data12  =8'h22,
    data13  =8'h23,
    data14  =8'h24,
    data15  =8'h25,
    data16  =8'h26,
    data17 =8'h27,
    data18 =8'h28,
    data19 =8'h29,
    data20 =8'h30,
    data21  =8'h31,
    data22  =8'h32,
    data23  =8'h33,
    data24  =8'h34,
    data25  =8'h35,
    data26  =8'h36,
    data27  =8'h37,
    data28  =8'h38,
    data29  =8'h39,
    data30  =8'h40,
    data31  =8'h41;
 initial
 begin
   //第一行显示 年-月-日  星期  //Mon Tue Wed  Thur Fri Sat Sun
   one_1<=" "; one_2<=" "; one_3<=" "; one_4<=" "; one_5<="-"; one_6<=" "; one_7<=" "; one_8<="-";
   one_9<=" ";one_10<=" ";one_11<=" ";one_12<=" ";one_13<=" ";one_14<=" ";one_15<=" ";one_16<=" ";
   //第二行显示 Clock:00-00-00
   two_1<="C"; two_2<="l"; two_3<="o"; two_4<="c"; two_5<="k"; two_6<=":"; two_7<=" "; two_8<=" ";
   two_9<="-";two_10<=" ";two_11<=" ";two_12<="-";two_13<=" ";two_14<=" ";two_15<=" ";two_16<=" "; 
   
   shi<=8'd0;fen<=8'd0;miao<=8'd0;
 end
//======================产生LCD 时序脉冲===========================    
 always @ (posedge clk )   //获得LCD时钟
 begin
  count<=count+1;
  if(count==32'd50000)
  begin
   count<=32'b0;
   lcd_clk<=~lcd_clk;
  end
 end
//=====================产生闪烁扫描时钟=========================== 
 reg [31:0] count2;
 reg  scan_flag;
 always @ (posedge clk or negedge rst) //获得校准时间选中闪烁状态
 begin
  if(!rst)
  begin
   scan_flag<=1'b0;
  end
  else
  begin
   count2<=count2+1;
   if(count2==32'd10000000)
   begin
    count2<=32'b0;
    scan_flag<=~scan_flag;
   end
  end
 end
//====================产生按键标志位================================= 
 reg [3:0] flag;
 always @ (posedge clk or negedge rst )
 begin
  if(!rst)
  begin
   flag<=4'b0;
  end
  else
  if(key1)
  begin
   flag<=flag+1'b1;
   if(flag==4'b1000)
    flag<=4'b0000;
  end
 end

//===================计时以及校准=======================================
 reg[3:0] week;
 reg[7:0] dat_flag;
 always @ (posedge clk or negedge rst )   //时钟计数器
 begin
  if(!rst)
  begin //初始化显示 第一行 2020-07-11 Sat     第二行：Clock:00-00-00
   shi<=8'b0;fen<=8'b0;miao<=8'b0;
   month<=8'd7;dat<=8'd11;year<=16'd2020;week<=4'd5;
   count1<=1'b0;
   two_7<= (shi/8'd10)+8'b00110000;
   two_8<= (shi%8'd10)+8'b00110000;
   two_10<=(fen/8'd10)+8'b00110000;
   two_11<=(fen%8'd10)+8'b00110000;
   two_13<=(miao/8'd10)+8'b00110000;
   two_14<=(miao%8'd10)+8'b00110000;
   one_1<=(year/16'd1000)+8'b00110000;
   one_2<=((year%16'd1000)/16'd100)+8'b00110000;
   one_3<=((year%16'd100)/8'd10)+8'b00110000;
   one_4<=(year%8'd10)+8'b00110000;
   one_6<=(month/8'd10)+8'b00110000;
   one_7<=(month%8'd10)+8'b00110000;
   one_9<=(dat/8'd10)+8'b00110000;
   one_10<=(dat%8'd10)+8'b00110000;
  end
  else
  begin
   two_7<= (shi/8'd10)+8'b00110000;
   two_8<= (shi%8'd10)+8'b00110000;
   two_10<=(fen/8'd10)+8'b00110000;
   two_11<=(fen%8'd10)+8'b00110000;
   two_13<=(miao/8'd10)+8'b00110000;
   two_14<=(miao%8'd10)+8'b00110000;
   one_1<=(year/16'd1000)+8'b00110000;
   one_2<=((year%16'd1000)/16'd100)+8'b00110000;
   one_3<=((year%16'd100)/8'd10)+8'b00110000;
   one_4<=(year%8'd10)+8'b00110000;
   one_6<=(month/8'd10)+8'b00110000;
   one_7<=(month%8'd10)+8'b00110000;
   one_9<=(dat/8'd10)+8'b00110000;
   one_10<=(dat%8'd10)+8'b00110000;
   // 判断是否为31天的月份
   if(month==8'd1||month==8'd3||month==8'd5||month==8'd7||month==8'd8||month==8'd10||month==8'd12)
    dat_flag<=8'd31;
   // 判断是否为30天的月份
   else if(month==8'd4||month==8'd6||month==8'd9||month==8'd11)
    dat_flag<=8'd30;
   // 判断是否为闰年和平年
   else if(month==8'd2)
   begin
    if(year % 4 == 0 && year % 100 != 0 || year % 400 == 0)
     dat_flag<=28;
    else dat_flag<=27;
   end
   case (week)
   //星期  //Mon Tue Wed  Thu Fri Sat Sun
    4'b0000 : //1
    begin
     one_13<="M";one_14<="o";one_15<="n";
    end
    4'b0001 : //2
    begin
     one_13<="T";one_14<="u";one_15<="e";
    end
    4'b0010 : //3
    begin
     one_13<="W";one_14<="e";one_15<="d";
    end    
    4'b0011 : //4
    begin
     one_13<="T";one_14<="h";one_15<="u";
    end    
    4'b0100 : //5
    begin
     one_13<="F";one_14<="r";one_15<="i";
    end
    4'b0101 : //6
    begin
     one_13<="S";one_14<="a";one_15<="t";
    end
    4'b0110 : //7
    begin
     one_13<="S";one_14<="u";one_15<="n";
    end
   endcase
   
   case(flag)
   4'b0000 :
    begin
     en_sel<=1'b1;     
     count1<=count1+1'b1;
     if(count1==32'd49999999)
     begin
      count1<=1'b0;
      miao<=miao+1'b1;
      if(miao==8'd59)
      begin
       miao<=1'b0;
       fen<=fen+1'b1;
       if(fen==8'd59)
       begin
        fen<=1'b0;
        shi<=shi+1'b1;
        if(shi==8'd23)
        begin
         shi<=1'b0;
         dat<=dat+1'b1;
         week<=week+1'b1;
         if(week==4'b0110)
          week<=1'b1;
         if(dat==dat_flag)
         begin
          dat<=8'd1;
          month<=month+1'b1;
          if(month==8'd12)
          begin
           month<=8'd1;
           year<=year+1'b1;
           if(year==16'd9999)
            year<=16'd0; //可以计1万年
          end
         end         
        end
       end
      end
     end
    end
   4'b0001 :
    begin
     count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;year<=year;month<=month;dat<=dat;week<=week;
    end
   4'b0010 : //调年
    begin
     case(scan_flag)
     1'b0:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
       one_1<=8'd20;one_2<=8'd20;one_3<=8'd20;one_4<=8'd20;
      end
     1'b1:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
      end
     endcase
     if(key2) //加数
     begin
      year<=year+1'b1;
      if(year==16'd9999)
       year<=16'd0;
     end
     if(key3) //减数
     begin
      year<=year-1'b1;
      if(year==16'd0)
       year<=16'd9999;
     end
    end
   4'b0011 : //调月
    begin
     case(scan_flag)
     1'b0:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
       one_6<=8'd20;one_7<=8'd20;
      end
     1'b1:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
      end
     endcase
     if(key2) //加数
     begin
      month<=month+1'b1;
      if(month==8'd12)
       month<=8'd0;
     end
     if(key3) //减数
     begin
      month<=month-1'b1;
      if(month==8'd0)
       month<=8'd12;
     end
    end    
   4'b0100 : //调日
    begin
     case(scan_flag)
     1'b0:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
       one_9<=8'd20;one_10<=8'd20;
      end
     1'b1:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
      end
     endcase
     if(key2) //加数
     begin
      dat<=dat+1'b1;
      if(dat==dat_flag)
       dat<=8'd0;
     end
     if(key3) //减数
     begin
      dat<=dat-1'b1;
      if(dat==8'd0)
       dat<=dat_flag;
     end
    end     
   4'b0101 : //调星期
    begin
     case(scan_flag)
     1'b0:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
       one_13<=8'd20;one_14<=8'd20;one_15<=8'd20;
      end
     1'b1:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
      end
     endcase
     if(key2) //加数
     begin
      week<=week+1'b1;
      if(week==4'd6)
       week<=4'd0;
     end
     if(key3) //减数
     begin
      week<=week-1'b1;
      if(week==4'd0)
       week<=4'd7;
     end
    end 
   4'b0110 : //调时
    begin
     case(scan_flag)
     1'b0:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
       two_7<= 8'd20;
       two_8<= 8'd20;
      end
     1'b1:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
      end
     endcase
     if(key2) //加数
     begin
      shi<=shi+8'b00000001;
      if(shi==8'd23)
       shi<=8'b0;
     end
     if(key3) //减数
     begin
      shi<=shi-8'b00000001;
      if(shi==8'b0)
       shi<=23;
     end
    end
   4'b0111 : //调分
    begin
     case(scan_flag)
     1'b0:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
       two_10<=8'd20;
       two_11<=8'd20;
      end
     1'b1:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
      end
     endcase
     if(key2) //加数
     begin
      fen<=fen+8'b00000001;
      if(fen==8'd59)
       fen<=8'b0;
     end
     if(key3) //减数
     begin
      fen<=fen-8'b00000001;
      if(fen==8'b0)
       fen<=59;
     end
    end    
   4'b1000 : //调秒
    begin
     case(scan_flag)
     1'b0:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
       two_13<=8'd20;
       two_14<=8'd20;
      end
     1'b1:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
      end
     endcase
     if(key2) //加数
     begin
      miao<=miao+8'b00000001;
      if(miao==8'd59)
       miao<=8'b0;
     end
     if(key3) //减数
     begin
      miao<=miao-8'b00000001;
      if(miao==8'b0)
       miao<=59;
     end
    end
   endcase
  end   
 end

 
 always @(posedge lcd_clk  )
 begin
   case(next)
    state0 :
     begin rs<=1'b0; data<=8'h38; next<=state1; end
    state1 :
     begin rs<=1'b0; data<=8'h0e; next<=state2; end
    state2 :
     begin rs<=1'b0; data<=8'h06; next<=state3; end
    state3 :
     begin rs<=1'b0; data<=8'h01; next<=state4; end 
         
    state4 :
     begin rs<=1'b0; data<=8'h80; next<=data0; end //显示第一行
    data0 :
     begin rs<=1'b1; data<=one_1; next<=data1 ; end
    data1 :
     begin rs<=1'b1; data<=one_2; next<=data2 ; end
    data2 :
     begin rs<=1'b1; data<=one_3; next<=data3 ; end
    data3 :
     begin rs<=1'b1; data<=one_4; next<=data4 ; end
    data4 :
     begin rs<=1'b1; data<=one_5; next<=data5 ; end
    data5 :
     begin rs<=1'b1; data<=one_6; next<=data6 ; end
    data6 :
     begin rs<=1'b1; data<=one_7; next<=data7 ; end
    data7 :
     begin rs<=1'b1; data<=one_8; next<=data8 ; end
    data8 :
     begin rs<=1'b1; data<=one_9; next<=data9 ; end
    data9 :
     begin rs<=1'b1; data<=one_10; next<=data10 ; end
    data10 :
     begin rs<=1'b1; data<=one_11; next<=data11 ; end
    data11 :
     begin rs<=1'b1; data<=one_12; next<=data12 ; end
    data12 :
     begin rs<=1'b1; data<=one_13; next<=data13 ; end
    data13 :
     begin rs<=1'b1; data<=one_14; next<=data14 ; end
    data14 :
     begin rs<=1'b1; data<=one_15; next<=data15 ; end
    data15 :
     begin rs<=1'b1; data<=one_16; next<=state5 ; end
      
    state5:  
     begin rs<=1'b0;data<=8'hC0; next<=data16; end //显示第二行
    data16 :
     begin rs<=1'b1; data<=two_1; next<=data17 ; end
    data17 :
     begin rs<=1'b1; data<=two_2; next<=data18 ; end
    data18 :
     begin rs<=1'b1; data<=two_3; next<=data19 ; end
    data19 :
     begin rs<=1'b1; data<=two_4; next<=data20 ; end
    data20 :
     begin rs<=1'b1; data<=two_5; next<=data21 ; end
    data21 :
     begin rs<=1'b1; data<=two_6; next<=data22 ; end
    data22 :
     begin rs<=1'b1; data<=two_7; next<=data23 ; end
    data23 :
     begin rs<=1'b1; data<=two_8; next<=data24 ; end
    data24 :
     begin rs<=1'b1; data<=two_9; next<=data25 ; end
    data25 :
     begin rs<=1'b1; data<=two_10; next<=data26 ; end
    data26 :
     begin rs<=1'b1; data<=two_11; next<=data27 ; end
    data27 :
     begin rs<=1'b1; data<=two_12; next<=data28 ; end
    data28 :
     begin rs<=1'b1; data<=two_13; next<=data29 ; end
    data29 :
     begin rs<=1'b1; data<=two_14; next<=data30 ; end
    data30 :
     begin rs<=1'b1; data<=two_15; next<=data31 ; end
    data31 :
     begin rs<=1'b1; data<=two_16; next<=scan ; end
     
    scan :   //交替更新第一行和第二行数据      
    begin
     next<=state4;
    end
    default:   next<=state0;
   endcase
 end
 assign en=lcd_clk && en_sel;
 assign rw=1'b0;
 
 
  //闹钟跑表
 parameter     _0 = 7'b1000000, _1 = 7'b1111001, _2 = 7'b0100100,
			 	  _3 = 7'b0110000, _4 = 7'b0011001, _5 = 7'b0010010,
			 	  _6 = 7'b0000010, _7 = 7'b1111000, _8 = 7'b0000000,
				  _9 = 7'b0010000, _10 = 7'b1111111;


				  
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

		

	



//module watchkeeping_module  
	  
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
 
 
 //时钟闹钟比较
output Led_Out1; 
wire [7:0] FEN;
wire [7:0] SHI;	
reg Led_Out1;	
assign FEN = MinL +MinH*10;
assign SHI = HourL +HourH*10;
always @ (posedge clk)
    begin 
	   if ( (FEN == fen) && (SHI == shi) )
			Led_Out1 = 1;
		else  
		  Led_Out1 = 0;
	 end
 
 
 
 


 
endmodule
