module Buzzer_module
(
  clk,
  fen, miao,
  led_Out 
);

input clk;
input [7:0] fen;
input [7:0] miao;
output led_Out;


  reg	led_Out;
	always @( posedge clk )
		begin
			if( fen==0 && miao== 0  )		//While Time = 00'00"
				led_Out <= 1;
			else if( fen== 0 && miao== 1 )		
				led_Out<= 1;	
			else if( fen== 0 && miao== 2 )		
				led_Out<= 1;	
			else
				led_Out <= 0;
		end
		
endmodule
