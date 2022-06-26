/******************************************************/
module viterbi_encode9(X,Y,Clock,Reset); 
/******************************************************/
//设定输入、时钟和重设
input X, Clock, Reset;
output [1:0] Y; 
wire [1:0] Yt;
wire X, Clock, Reset;
wire [8:0] PolyA, PolyB;
wire [8:0] wA, wB, ShReg;


   assign   PolyA = 9'b110_101_111;		//两个多项式
   assign   PolyB = 9'b100_011_101; 
 
   assign wA = PolyA & ShReg;			//取出多项式对应的寄存器。
   assign wB = PolyB & ShReg; 
 
   assign ShReg[8] = X;					//输入信号
   pDFF dff7(ShReg[8], ShReg[7], Clock, Reset);		//移位
   pDFF dff6(ShReg[7], ShReg[6], Clock, Reset);    
   pDFF dff5(ShReg[6], ShReg[5], Clock, Reset); 
   pDFF dff4(ShReg[5], ShReg[4], Clock, Reset); 
   pDFF dff3(ShReg[4], ShReg[3], Clock, Reset); 
   pDFF dff2(ShReg[3], ShReg[2], Clock, Reset); 
   pDFF dff1(ShReg[2], ShReg[1], Clock, Reset); 
   pDFF dff0(ShReg[1], ShReg[0], Clock, Reset); 
 
   //输出信号
   assign Yt[1] = wA[0] ^ wA[1] ^ wA[2] ^ wA[3] ^ wA[4] ^ wA[5] ^ wA[6] ^ wA[7] ^ wA[8]; 
   assign Yt[0] = wB[0] ^ wB[1] ^ wB[2] ^ wB[3] ^ wB[4] ^ wB[5] ^ wB[6] ^ wB[7] ^ wB[8]; 
 
   pDFF dffy1(Yt[1], Y[1], Clock, Reset); 
   pDFF dffy0(Yt[0], Y[0], Clock, Reset); 
	
	
endmodule