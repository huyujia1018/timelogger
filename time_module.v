module time_module
(
clk,
flag,
rst,
key2,key3,
shi,fen,miao,
year,month,dat,
week,
en_sel,
scan_flag
);

input clk;
input [3:0] flag;
input rst;
input key2,key3;
output [7:0] shi,fen,miao;
output [7:0] month,dat;
output [14:0] year;
output [3:0] week;
output en_sel;
output scan_flag;


 reg [14:0] year;
 reg [7:0] shi,fen,miao,month,dat;
 reg en_sel;



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

 
//时钟计数器
 reg [31:0] count1;
 reg[3:0] week;
 reg[7:0] dat_flag;
 always @ (posedge clk or negedge rst )   
 begin
   if(!rst)
   begin //初始化显示 第一行 2020-07-09  Thu    第二行：Clock:00-00-00
   shi<=8'b0;fen<=8'b0;miao<=8'b0;
   month<=8'd7;dat<=8'd9;year<=16'd2020;week<=4'd3;
	count1 <= 32'd0;
	end
	else
	 begin 
    shi<=shi;fen<=fen;miao<=miao;
    month<=month;dat<=dat;year<=year;week<=week;	

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
     count1<=32'b0; 
	  shi<=shi;fen<=fen;miao<=miao;year<=year;month<=month;dat<=dat;week<=week;
    end
   4'b0010 : //调年
    begin
     case(scan_flag)
     1'b0:
      begin
       count1<=32'b0; //shi<=shi;fen<=fen;miao<=miao;
       year<=15'd80;
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
       month<= 8'd80;
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
       dat<= 8'd80;
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
       week<= 8'd80;
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
       shi<= 8'd80;
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
       fen<= 8'd80;
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
       miao<= 8'd80;
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
 
endmodule
