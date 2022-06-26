
`include "params.v"
/*-----------------------------------*/
// Module: CONTROL
// File : control.v
// Description : Description of Control Unit in Viterbi Decoder 
// Simulator : Modelsim 10.5 / Windows 10/11 
/*-----------------------------------*/
// Revision Number : 1
// Description : Initial Design
/*-----------------------------------*/
module CONTROL (Reset, CLOCK, Clock1, Clock2, ACSPage, ACSSegment, Active, CompareStart, Hold, Init, TB_EN);
	input Reset, CLOCK, Active;
	output [`WD_FSM-1:0] ACSSegment; 
	output [`WD_DEPTH-1:0] ACSPage;
	output Clock1, Clock2;
	output Hold, Init, CompareStart; 
	output TB_EN;//回溯使能信号,acspage为62且acssegment达到63 该信号置1 开始回溯
	
	reg [`WD_FSM-1:0] ACSSegment; 
	reg [`WD_DEPTH-1:0] ACSPage;
	reg Init,Hold;
	wire EVENT_1,EVENT_0;
	reg TB_EN;
	reg CompareStart;
	reg [3:0] CompareCount;
	reg count,Clock1, Clock2;
	
	always @(posedge CLOCK or negedge Reset)   //对clock进行四分频clock1与clock2相差四分之一个周期
	  if (~Reset) count <= 0; 
	  else count <= ~count;
	always @(posedge CLOCK or negedge Reset) 
	  begin
		  if (~Reset) begin
			  Clock1 <= 0;
			  Clock2 <= 0; end
		  else begin
			  if (count) Clock1 <=~Clock1;
			  if (~count) Clock2 <= ~Clock2; 
		  end
	  end

	assign EVENT_1 = (ACSSegment == 6'h3E); //一个code迭代计算结束，置1
	assign EVENT_0 = (ACSSegment == 6'h3F);
	always @(posedge Clock1 or negedge Reset) //一个code迭代计算开始，置1
	  begin
	  if (~Reset) begin
		{ACSPage,ACSSegment} <= 'hFFFFF; Init <=0;
		Hold <= 0;
		TB_EN <= 0;
	  end
	  else if (Active)
	begin
	// 迭代一次ACSSegment +1，每迭代64次ACSPage+1
	{ACSPage,ACSSegment} <= {ACSPage,ACSSegment} + 1;
	if (EVENT_1) begin Init <= 0; Hold <= 1; 
	end//一个code迭代计算结束
	else if (EVENT_0) begin Init <= 1; Hold <= 0; end 
	//一个code跌打计算开始
	else begin {Init,Hold} <= 0; end
	//迭代计算中置0 
	if ((ACSSegment == 'h3F) && (ACSPage == 'h3E)) TB_EN <= 1; end //64个code计算结束，开始回溯路径
	end
	always @(posedge Clock2 or negedge Reset) 
	begin
	if (~Reset) begin
	CompareCount <= 0;
	CompareStart <= 0; end
	else begin
	  if (~CompareStart && EVENT_1) CompareCount <= CompareCount + 1;//一个code迭代计算结束，ACSegment为62，CompareCount + 1
	  if (CompareCount == `CONSTRAINT-1 && EVENT_0) CompareStart <= 1;//完成8个code的计算，CompareStart <= 1，开始进行比较路径
	 
	end
	end 
endmodule