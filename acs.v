//acs.v

`include "params.v"
/*-----------------------------------*/
// Module: ACSUNIT
// Author: Xia Chengzhuo 夏成卓
// File : acs.v
// Description : Description of ACS Unit in Viterbi Decoder 
// Simulator : Modelsim 10.5 / Windows 10/11 
/*-----------------------------------*/
// Revision Number : 1
// Description : Initial Design，该模块主要实现比选存的功能


/*-----------------------------------*/
module ACSUNIT (Reset, Clock1, Clock2, Active, Init, Hold, CompareStart, ACSSegment, Distance, Survivors, LowestState,
				MMReadAddress, MMWriteAddress, MMBlockSelect, MMMetric, MMPathMetric);
/*-----------------------------------*/ 
// ACS UNIT consists of :
// - 4 ACS modules (ACS)
// - RAM Interface
// - State with smallest metric finder (LOWESTPICK) 
// Lowest Pick block 最小路径选择
 /*-----------------------------------*/
//声明输入端口
input Reset, Clock1, Clock2, Active, Init, Hold, CompareStart; 
input [`WD_FSM-1:0] ACSSegment;
input [`WD_DIST*2*`N_ACS-1:0] Distance;
input [`WD_METR*2*`N_ACS-1:0] MMPathMetric;
//声明输出端口
output [`N_ACS-1:0] Survivors;// to Survivor Memory 输出到留存路径存储器 
//toTBUnit 输出到TB单元
output [`WD_STATE-1:0] LowestState;
// to Memory Metric 输出到内存度量
output [`WD_FSM-2:0] MMReadAddress; //mm输入地址
output [`WD_FSM-1:0] MMWriteAddress; //mm输出地址
output MMBlockSelect;//mm模块选择
output [`WD_METR*`N_ACS-1:0] MMMetric; 
//声明变量
wire [`WD_DIST-1:0] Distance7,Distance6,Distance5,Distance4, Distance3,Distance2,Distance1,Distance0;
wire [`WD_METR*`N_ACS-1:0] Metric;
wire [`WD_METR-1:0] Metric0, Metric1, Metric2, Metric3;
wire [`WD_METR*2*`N_ACS-1:0] PathMetric;
wire [`WD_METR-1:0] PathMetric7,PathMetric6,PathMetric5,PathMetric4,PathMetric3,PathMetric2,PathMetric1,PathMetric0;
wire [`WD_METR-1:0] LowestMetric;
//赋值
assign {Distance7,Distance6,Distance5,Distance4, Distance3,Distance2,Distance1,Distance0} = Distance; 
assign {PathMetric7,PathMetric6,PathMetric5,PathMetric4,PathMetric3,PathMetric2,PathMetric1,PathMetric0} = PathMetric;//路径码距
ACS acs0 (.CompareEnable(CompareStart), .Distance1(Distance1),.Distance0(Distance0),
		.PathMetric1(PathMetric1),.PathMetric0(PathMetric0), .Survivor(ACSData0), .Metric(Metric0));//连接ACS0-3四个block
ACS acs1 (.CompareEnable(CompareStart), .Distance1(Distance3),.Distance0(Distance2),
		.PathMetric1(PathMetric3),.PathMetric0(PathMetric2), .Survivor(ACSData1), .Metric(Metric1));
ACS acs2 (.CompareEnable(CompareStart), .Distance1(Distance5),.Distance0(Distance4),
		.PathMetric1(PathMetric5),.PathMetric0(PathMetric4), .Survivor(ACSData2), .Metric(Metric2));
ACS acs3 (.CompareEnable(CompareStart), .Distance1(Distance7),.Distance0(Distance6),
		.PathMetric1(PathMetric7),.PathMetric0(PathMetric6), .Survivor(ACSData3), .Metric(Metric3));
RAMINTERFACE raminterface (.Reset(Reset), .Clock2(Clock2), .Hold(Hold), .ACSSegment(ACSSegment), 
		.Metric(Metric), .PathMetric(PathMetric), .MMReadAddress(MMReadAddress), 
		.MMWriteAddress(MMWriteAddress), .MMBlockSelect(MMBlockSelect), .MMMetric(MMMetric),.MMPathMetric(MMPathMetric));//RAMINTERFACE 例化
LOWESTPICK lowestpick (.Reset(Reset), .Active(Active), .Hold(Hold), .Init(Init), .Clock1(Clock1),
		.Clock2(Clock2), .ACSSegment(ACSSegment), .Metric3(Metric3), .Metric2(Metric2), .Metric1(Metric1), 
		.Metric0(Metric0),.LowestMetric(LowestMetric), .LowestState(LowestState));//LOWESTPICK 例化
assign Metric = {Metric3, Metric2, Metric1, Metric0};//度量,4个状态，每个两个进入取min得到一个
assign Survivors = {ACSData3,ACSData2,ACSData1,ACSData0};//幸存路径，4个状态，每个剩一个路径
endmodule


/*-----------------------------------*/
module RAMINTERFACE (Reset, Clock2, Hold, ACSSegment, Metric, PathMetric, MMReadAddress, MMWriteAddress, 
					MMBlockSelect,MMMetric, MMPathMetric);//RAM接口模块
/*-----------------------------------*/
// connection to ACS Unit 连接到 ACS 单元
// input和output端口声明
input Reset, Clock2, Hold;
input [`WD_FSM-1:0] ACSSegment;
input [`WD_METR*`N_ACS-1:0] Metric;
input [`WD_METR*2*`N_ACS-1:0] MMPathMetric; 

output [`WD_METR*2*`N_ACS-1:0] PathMetric;// connection to metric memory 连接到度量内存 
output [`WD_METR*`N_ACS-1:0] MMMetric; 
output [`WD_FSM-2:0] MMReadAddress; //mm输入地址
output [`WD_FSM-1:0] MMWriteAddress; //mm输出地址
output MMBlockSelect;

reg [`WD_FSM-2:0] MMReadAddress;
reg MMBlockSelect;

always @(ACSSegment or Reset)//ACSSegment或Reset变化执行
		if (~Reset) MMReadAddress <= 0;//Reset=0，MMReadAddress非阻塞赋值为0
		else MMReadAddress <= ACSSegment [`WD_FSM-2:0];//Reset=1,MMReadAddress<=ACSSegment [`WD_FSM-2:0]
always @(posedge Clock2 or negedge Reset) //Clock2上升沿或者Reset下降沿时执行
	begin
	  if (~Reset) MMBlockSelect <=0;//Reset=0时，MMBlockSelect非阻塞赋值为0
	  else if (Hold) MMBlockSelect <= ~MMBlockSelect;  //Hold=1,MMBlockSelect取反
	end
assign PathMetric = MMPathMetric; 
assign MMMetric = Metric;
assign MMWriteAddress = ACSSegment;
endmodule


/*-----------------------------------*/
module ACS (CompareEnable, Distance1, Distance0, PathMetric1,
PathMetric0, Survivor, Metric);
//
//ACS Module, based on Modified Comparison Rule, [Shung90] 
//ACS 模块，基于修改比较规则 
/*-----------------------------------*/
//input和output端口声明
input [`WD_DIST-1:0] Distance1,Distance0;
input [`WD_METR-1:0] PathMetric1,PathMetric0; 
input CompareEnable;
output Survivor;
output [`WD_METR-1:0] Metric;
//声明变量
wire [`WD_METR-1:0] ADD0, ADD1;
wire Survivor;
wire [`WD_METR-1:0] Temp_Metric, Metric;
//赋值
assign ADD0 = Distance0 + PathMetric0;//分支度量相加，得到新的汉明距离
assign ADD1 = Distance1 + PathMetric1;

COMPARATOR comparator1(.CompareEnable(CompareEnable), .Metric1(ADD1), .Metric0(ADD0), .Survivor(Survivor));//对比较器实例化
assign Temp_Metric = (Survivor)? ADD1: ADD0; //Survivor=1，Temp_Metric=ADD1;Survivor=0,Temp_Metric=ADD0
assign Metric = (CompareEnable)? Temp_Metric:ADD0;//CompareEnable=1,Metric=Temp_Metric;CompareEnable=0,Metric=ADD0
endmodule


/*-----------------------------------*/
module COMPARATOR (CompareEnable, Metric1, Metric0, Survivor);
//
// 2's complement comparator to find which is the smaller between Metric1 and Metric0.
// 2 的补码比较器，找出 Metric1 和 Metric0 之间的较小值
// Survivor : 1 --> Metric1 is the smaller one. Metric1 较小
// 0 --> Metric0 is the smaller one. 
/*-----------------------------------*/
//input和output端口声明
input [`WD_METR-1:0] Metric1,Metric0; 
input CompareEnable;
output Survivor;

wire M1msb, M0msb;
wire [`WD_METR-1:0] M1unsigned, M0unsigned;
wire M1msb_xor_M0msb, M1unsignedcompM0; 

assign M1msb = Metric1 [`WD_METR-1];
assign M0msb = Metric0 [`WD_METR-1];
assign M1unsigned = {1'b0, Metric1 [`WD_METR-2:0]};
assign M0unsigned = {1'b0, Metric0 [`WD_METR-2:0]};
assign M1msb_xor_M0msb = M1msb ^ M0msb;// Metric0和Metric1的最高位异或，64位迭代中最高位始终为0
assign M1unsignedcompM0 = (M1unsigned > M0unsigned)? 0:1;// Metric0>Metric1, M1unsignedcompM0=0;Metric0<Metric1, M1unsignedcompM0=1
assign Survivor = (CompareEnable) ?M1msb_xor_M0msb ^ M1unsignedcompM0:'b0;//CompareEnable=1,Survivor=M1msb_xor_M0msb;CompareEnable=0,Survivor=M1unsignedcompM0
endmodule


/*-----------------------------------*/
module LOWESTPICK (Reset, Active, Hold, Init, Clock1, Clock2, ACSSegment,
Metric3, Metric2, Metric1, Metric0, LowestMetric, LowestState);
//
// This module is used to find which of 256 states has the smallest metric. //该模块用于查找 256 个状态中具有最小度量的状态。
//码器输入(X)，并且最低度量值应为 0) 
/*-----------------------------------*/
//input和output端口声明
input Reset, Active, Clock1, Clock2, Hold, Init;
input [`WD_FSM-1:0] ACSSegment;
input [`WD_METR-1:0] Metric3, Metric2, Metric1, Metric0;
output [`WD_METR-1:0] LowestMetric;
output [`WD_STATE-1:0] LowestState;

//变量声明
reg [`WD_METR-1:0] LowestMetric, Reg_Metric; 
reg [`WD_STATE-1:0] LowestState, Reg_State;
wire [`WD_METR-1:0] MetricCompareResult; 
wire [`WD_STATE-1:0] StateCompareResult;
wire [`WD_METR-1:0] Lowest_Metric4; //用于4个输出中的存放最小码距
wire [`WD_STATE-1:0] Lowest_State4; //用于4个输出中的存放最小度量

// find state with the lowest metrics for current input 
// 找到当前输入的最低度量的状态
LOWEST_OF_FOUR lowof4 (.Active(Active), .ACSSegment(ACSSegment), .Metric3(Metric3), .Metric2(Metric2),
		.Metric1(Metric1), .Metric0(Metric0),.Lowest_State4(Lowest_State4), .Lowest_Metric4(Lowest_Metric4));

// compare the 'previous lowest metric' with the'lowest metric of current input'
// 将“先前最低度量”与“当前输入的最低度量”进行比较
COMPARATOR comp (.CompareEnable(Active), .Metric1(Reg_Metric), .Metric0(Lowest_Metric4), .Survivor(CompareBit));
assign MetricCompareResult = (CompareBit) ? Reg_Metric:Lowest_Metric4; //CompareBit=1,MetricCompareResult=Reg_Metric;CompareBit=0,MetricCompareResult=Lowest_Metric4
assign StateCompareResult = (CompareBit) ? Reg_State:Lowest_State4; //CompareBit=1,StateCompareResult=Reg_State;CompareBit=0,StateCompareResult=Lowest_State4
 
always @(negedge Clock2 or negedge Reset)//当Clock2或者Reset下降沿时执行
begin
if (~Reset) begin //Reset=0
  Reg_Metric <=0;
  Reg_State <= 0; 
  end
else if (Active) begin
  if (Init) 
	  begin
		Reg_Metric <= Lowest_Metric4;
		Reg_State <= Lowest_State4;//初始化时将当前输入最低度量和状态赋值给之前的最低度量和状态
	  end
  else 
	  begin
		Reg_Metric <= MetricCompareResult;
		Reg_State <= StateCompareResult;  //将比较结果赋值给之前的最低量度和状态
	  end
end end

always @(negedge Clock1 or negedge Reset) //Clock1或者Reset的下降沿时执行输出
begin
if (~Reset) begin
LowestMetric <=0;
  LowestState <= 0; end
else if (Active) begin
if (Hold)
begin LowestMetric <= Reg_Metric;
LowestState <= Reg_State; end
end end
endmodule


/*-----------------------------------*/
module LOWEST_OF_FOUR (Active, ACSSegment, Metric3, Metric2, Metric1,
Metric0, Lowest_State4, Lowest_Metric4);
//
// This module is used to find ONE STATE among FOUR survivor and metric
// calculated in every cycle which has the smallest metric.
// 该模块用于在四个留存中找到一个状态，其在每个周期中计算出具有最的小度量。
/*-----------------------------------*/
//input和output端口声明
input Active;
input [`WD_FSM-1:0] ACSSegment;
input [`WD_METR-1:0] Metric3, Metric2, Metric1, Metric0;
output [`WD_STATE-1:0] Lowest_State4; output [`WD_METR-1:0] Lowest_Metric4;
wire Surv1, Surv2, Surv3, Bit_One;
wire [`WD_METR-1:0] MetricX, MetricY;

COMPARATOR comp1 (.CompareEnable(Active), .Metric1(Metric1), .Metric0(Metric0), .Survivor(Surv1)); // 比较metric1和Metric0
COMPARATOR comp2 (.CompareEnable(Active), .Metric1(Metric3), .Metric0(Metric2), .Survivor(Surv2)); // 比较metric3和metric2
assign MetricX = (Surv1)?Metric1:Metric0;// 把Metric1和Metric0中较小的值赋给MetricX 
assign MetricY = (Surv2)?Metric3:Metric2;// 把Metric3和Metric2中较小的值赋给MetricY

COMPARATOR comp3 (.CompareEnable(Active), .Metric1(MetricY), .Metric0(MetricX), .Survivor(Surv3));// 比较 MetricY 和MetricX.
assign Lowest_State4 = {ACSSegment, Surv3, Bit_One};//以最小度量分配状态
assign Lowest_Metric4 = (Surv3)?MetricY:MetricX;//分配最小度量
endmodule