`include "params.v"
`timescale 1 ns/ 1 ns
module control_test();
reg Reset, CLOCK, Active; 
 
wire [`WD_FSM-1:0] ACSSegment; 
wire [`WD_DEPTH-1:0] ACSPage; 
wire Clock1, Clock2; 
wire Hold, Init, CompareStart; 
wire TB_EN; 

CONTROL ctrl(Reset, CLOCK, Clock1, Clock2, ACSPage, ACSSegment, Active,  
		CompareStart, Hold, Init, TB_EN); //实例化
               
   initial CLOCK = 0; 
   always #(`HALF/2) CLOCK = ~CLOCK; //原始时钟，T=100 
   
   initial 
   begin   
      Reset = 1; Active =0;
      #200 Reset = 0;Active =0;//复位
      #300 Reset = 1;Active =1;//正常工作，输出控制信号
   end 
    
endmodule 