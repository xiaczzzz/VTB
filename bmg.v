`include "params.v"
/*-----------------------------------*/
// Module: BMG
// author : He Gongxu
// File : bmg.v
// Description :  Output branch metric of eight branches for four states in sequence (Vary with ASCSegment) 
// Simulator : Modelsim 6.5 / Windows 7/10 
/*-----------------------------------*/
// Revision Number : 1
// Description : Initial Design 
/*-----------------------------------*/
module BMG (Reset, Clock2, ACSSegment, Code, Distance);
	input Reset, Clock2;
	input [`WD_FSM-1:0] ACSSegment; 
	input [`WD_CODE-1:0] Code;
	output [`WD_DIST*2*`N_ACS-1:0] Distance;

	wire [`WD_STATE:0] PolyA, PolyB; 
	wire [`WD_STATE:0] wA, wB;
	assign PolyA = 9'b110_101_111; //使用多项式编码 
	assign PolyB = 9'b100_011_101;
	wire [`WD_STATE:0] B0,B1,B2,B3,B4,B5,B6,B7; 
	wire [`WD_CODE-1:0] G0,G1,G2,G3,G4,G5,G6,G7; 
	wire [`WD_DIST-1:0] D0,D1,D2,D3,D4,D5,D6,D7; 
	reg [`WD_CODE-1:0] CodeRegister;

	always @(posedge Clock2 or negedge Reset) begin
	if (~Reset) CodeRegister <= 0;
	// 要计算的分支输出
	// 输出距离
	else if (ACSSegment == 6'h3F) CodeRegister <= Code; end
	assign B0 = {ACSSegment,3'b000};//拼接三比特得到四个状态共八个分支的9比特路径ID
	assign B1 = {ACSSegment,3'b001}; 
	assign B2 = {ACSSegment,3'b010}; 
	assign B3 = {ACSSegment,3'b011};
	assign B4 = {ACSSegment,3'b100}; 
	assign B5 = {ACSSegment,3'b101}; 
	assign B6 = {ACSSegment,3'b110}; 
	assign B7 = {ACSSegment,3'b111};

	ENC en0(.PolyA(PolyA),.PolyB(PolyB),.BranchID(B0),.EncOut(G0)); assign G1 = ~G0;// 调用ENC，计算可能分支输出。G0,G1码距为1，与ployA ployB按位与得到结果相差一位，最终每位累加得到一比特结果相反=>G1=~G0,以下同理
	ENC en2(.PolyA(PolyA),.PolyB(PolyB),.BranchID(B2),.EncOut(G2)); assign G3 = ~G2;  
	ENC en4(.PolyA(PolyA),.PolyB(PolyB),.BranchID(B4),.EncOut(G4)); assign G5 = ~G4; 
	ENC en6(.PolyA(PolyA),.PolyB(PolyB),.BranchID(B6),.EncOut(G6)); assign G7 = ~G6;
	HARD_DIST_CALC hd0(.InputSymbol(CodeRegister),.BranchOutput(G0),.OutputDistance(D0));//调用HARD_DIST_CALC
	HARD_DIST_CALC hd1(.InputSymbol(CodeRegister),.BranchOutput(G1),.OutputDistance(D1));//计算输入codeRegister与分支输出G的码距
	HARD_DIST_CALC hd2(.InputSymbol(CodeRegister),.BranchOutput(G2),.OutputDistance(D2));
	HARD_DIST_CALC hd3(.InputSymbol(CodeRegister),.BranchOutput(G3),.OutputDistance(D3)); //D的所有可能取值为00，01，10 
	HARD_DIST_CALC hd4(.InputSymbol(CodeRegister),.BranchOutput(G4),.OutputDistance(D4));
	HARD_DIST_CALC hd5(.InputSymbol(CodeRegister),.BranchOutput(G5),.OutputDistance(D5));
	HARD_DIST_CALC hd6(.InputSymbol(CodeRegister),.BranchOutput(G6),.OutputDistance(D6));
	HARD_DIST_CALC hd7(.InputSymbol(CodeRegister),.BranchOutput(G7),.OutputDistance(D7));
	assign Distance = {D7,D6,D5,D4,D3,D2,D1,D0};
endmodule


//将D7到D0位接赋值给distance（16位）
/*-----------------------------------*/
module HARD_DIST_CALC (InputSymbol, BranchOutput, OutputDistance); 
/*--------------------------------------------------------*/
// author : He Gongxu
//执行 2 位汉明距离计算 
//输入为InputSymbol, BranchOutput;输出为OutputDistance 
//将分支输出BranchOutput与InputSymbol进行汉明距离计算，返回值放入 OutputDistance中
/*--------------------------------------------------------*/
	input [`WD_CODE-1:0] InputSymbol, BranchOutput;
	output [`WD_DIST-1:0] OutputDistance;
	reg [`WD_DIST-1:0] OutputDistance;

	wire MS, LS;
	assign MS = (InputSymbol[1] ^ BranchOutput[1]); //对应位异或，相同为0不同为1，赋值给MS，LS
	assign LS = (InputSymbol[0] ^ BranchOutput[0]);

	always @(MS or LS)
	   begin
	     OutputDistance<={1'b0,MS}+{1'b0,LS};
	   end
endmodule


// MS与LS相与得到OutputDistance[1]
//MS与LS异或得到OutputDistance[0]
/*-----------------------------------*/
module ENC (PolyA, PolyB, BranchID, EncOut); 
/*-----------------------------------*/
// author : He Gongxu
// 用于确定分支输出的编码器 //ENC模块用于生成维特比编码，BranchID代表路径编号 //将9位分支输入BranchID分别与PolyA和PolyB进行与操作，然后逐位进行异或即可得到 分支输出EncOut。
// delay : N/A
/*-----------------------------------*/
	input [`WD_STATE:0] PolyA,PolyB;
	input [`WD_STATE:0] BranchID;
	output [`WD_CODE-1:0] EncOut;
	wire [`WD_STATE:0] wA, wB;
	reg [`WD_CODE-1:0] EncOut;
	assign wA = PolyA & BranchID; //将9位路径ID分别与PolyA和PolyB进行与操作
	assign wB = PolyB & BranchID; 
	always @(wA or wB)
	  begin
	    EncOut[1] = wA[0]+wA[1]+wA[2]+wA[3]+wA[4]+wA[5]+wA[6]+wA[7]+wA[8]; // 逐位相加得到分支输出
        EncOut[0] = wB[0]+wB[1]+wB[2]+wB[3]+wB[4]+wB[5]+wB[6]+wB[7]+wB[8];
	  end
endmodule


