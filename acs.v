//acs.v

`include "params.v"
/*-----------------------------------*/
// Module: ACSUNIT
// Author: Xia Chengzhuo �ĳ�׿
// File : acs.v
// Description : Description of ACS Unit in Viterbi Decoder 
// Simulator : Modelsim 10.5 / Windows 10/11 
/*-----------------------------------*/
// Revision Number : 1
// Description : Initial Design����ģ����Ҫʵ�ֱ�ѡ��Ĺ���


/*-----------------------------------*/
module ACSUNIT (Reset, Clock1, Clock2, Active, Init, Hold, CompareStart, ACSSegment, Distance, Survivors, LowestState,
				MMReadAddress, MMWriteAddress, MMBlockSelect, MMMetric, MMPathMetric);
/*-----------------------------------*/ 
// ACS UNIT consists of :
// - 4 ACS modules (ACS)
// - RAM Interface
// - State with smallest metric finder (LOWESTPICK) 
// Lowest Pick block ��С·��ѡ��
 /*-----------------------------------*/
//��������˿�
input Reset, Clock1, Clock2, Active, Init, Hold, CompareStart; 
input [`WD_FSM-1:0] ACSSegment;
input [`WD_DIST*2*`N_ACS-1:0] Distance;
input [`WD_METR*2*`N_ACS-1:0] MMPathMetric;
//��������˿�
output [`N_ACS-1:0] Survivors;// to Survivor Memory ���������·���洢�� 
//toTBUnit �����TB��Ԫ
output [`WD_STATE-1:0] LowestState;
// to Memory Metric ������ڴ����
output [`WD_FSM-2:0] MMReadAddress; //mm�����ַ
output [`WD_FSM-1:0] MMWriteAddress; //mm�����ַ
output MMBlockSelect;//mmģ��ѡ��
output [`WD_METR*`N_ACS-1:0] MMMetric; 
//��������
wire [`WD_DIST-1:0] Distance7,Distance6,Distance5,Distance4, Distance3,Distance2,Distance1,Distance0;
wire [`WD_METR*`N_ACS-1:0] Metric;
wire [`WD_METR-1:0] Metric0, Metric1, Metric2, Metric3;
wire [`WD_METR*2*`N_ACS-1:0] PathMetric;
wire [`WD_METR-1:0] PathMetric7,PathMetric6,PathMetric5,PathMetric4,PathMetric3,PathMetric2,PathMetric1,PathMetric0;
wire [`WD_METR-1:0] LowestMetric;
//��ֵ
assign {Distance7,Distance6,Distance5,Distance4, Distance3,Distance2,Distance1,Distance0} = Distance; 
assign {PathMetric7,PathMetric6,PathMetric5,PathMetric4,PathMetric3,PathMetric2,PathMetric1,PathMetric0} = PathMetric;//·�����
ACS acs0 (.CompareEnable(CompareStart), .Distance1(Distance1),.Distance0(Distance0),
		.PathMetric1(PathMetric1),.PathMetric0(PathMetric0), .Survivor(ACSData0), .Metric(Metric0));//����ACS0-3�ĸ�block
ACS acs1 (.CompareEnable(CompareStart), .Distance1(Distance3),.Distance0(Distance2),
		.PathMetric1(PathMetric3),.PathMetric0(PathMetric2), .Survivor(ACSData1), .Metric(Metric1));
ACS acs2 (.CompareEnable(CompareStart), .Distance1(Distance5),.Distance0(Distance4),
		.PathMetric1(PathMetric5),.PathMetric0(PathMetric4), .Survivor(ACSData2), .Metric(Metric2));
ACS acs3 (.CompareEnable(CompareStart), .Distance1(Distance7),.Distance0(Distance6),
		.PathMetric1(PathMetric7),.PathMetric0(PathMetric6), .Survivor(ACSData3), .Metric(Metric3));
RAMINTERFACE raminterface (.Reset(Reset), .Clock2(Clock2), .Hold(Hold), .ACSSegment(ACSSegment), 
		.Metric(Metric), .PathMetric(PathMetric), .MMReadAddress(MMReadAddress), 
		.MMWriteAddress(MMWriteAddress), .MMBlockSelect(MMBlockSelect), .MMMetric(MMMetric),.MMPathMetric(MMPathMetric));//RAMINTERFACE ����
LOWESTPICK lowestpick (.Reset(Reset), .Active(Active), .Hold(Hold), .Init(Init), .Clock1(Clock1),
		.Clock2(Clock2), .ACSSegment(ACSSegment), .Metric3(Metric3), .Metric2(Metric2), .Metric1(Metric1), 
		.Metric0(Metric0),.LowestMetric(LowestMetric), .LowestState(LowestState));//LOWESTPICK ����
assign Metric = {Metric3, Metric2, Metric1, Metric0};//����,4��״̬��ÿ����������ȡmin�õ�һ��
assign Survivors = {ACSData3,ACSData2,ACSData1,ACSData0};//�Ҵ�·����4��״̬��ÿ��ʣһ��·��
endmodule


/*-----------------------------------*/
module RAMINTERFACE (Reset, Clock2, Hold, ACSSegment, Metric, PathMetric, MMReadAddress, MMWriteAddress, 
					MMBlockSelect,MMMetric, MMPathMetric);//RAM�ӿ�ģ��
/*-----------------------------------*/
// connection to ACS Unit ���ӵ� ACS ��Ԫ
// input��output�˿�����
input Reset, Clock2, Hold;
input [`WD_FSM-1:0] ACSSegment;
input [`WD_METR*`N_ACS-1:0] Metric;
input [`WD_METR*2*`N_ACS-1:0] MMPathMetric; 

output [`WD_METR*2*`N_ACS-1:0] PathMetric;// connection to metric memory ���ӵ������ڴ� 
output [`WD_METR*`N_ACS-1:0] MMMetric; 
output [`WD_FSM-2:0] MMReadAddress; //mm�����ַ
output [`WD_FSM-1:0] MMWriteAddress; //mm�����ַ
output MMBlockSelect;

reg [`WD_FSM-2:0] MMReadAddress;
reg MMBlockSelect;

always @(ACSSegment or Reset)//ACSSegment��Reset�仯ִ��
		if (~Reset) MMReadAddress <= 0;//Reset=0��MMReadAddress��������ֵΪ0
		else MMReadAddress <= ACSSegment [`WD_FSM-2:0];//Reset=1,MMReadAddress<=ACSSegment [`WD_FSM-2:0]
always @(posedge Clock2 or negedge Reset) //Clock2�����ػ���Reset�½���ʱִ��
	begin
	  if (~Reset) MMBlockSelect <=0;//Reset=0ʱ��MMBlockSelect��������ֵΪ0
	  else if (Hold) MMBlockSelect <= ~MMBlockSelect;  //Hold=1,MMBlockSelectȡ��
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
//ACS ģ�飬�����޸ıȽϹ��� 
/*-----------------------------------*/
//input��output�˿�����
input [`WD_DIST-1:0] Distance1,Distance0;
input [`WD_METR-1:0] PathMetric1,PathMetric0; 
input CompareEnable;
output Survivor;
output [`WD_METR-1:0] Metric;
//��������
wire [`WD_METR-1:0] ADD0, ADD1;
wire Survivor;
wire [`WD_METR-1:0] Temp_Metric, Metric;
//��ֵ
assign ADD0 = Distance0 + PathMetric0;//��֧������ӣ��õ��µĺ�������
assign ADD1 = Distance1 + PathMetric1;

COMPARATOR comparator1(.CompareEnable(CompareEnable), .Metric1(ADD1), .Metric0(ADD0), .Survivor(Survivor));//�ԱȽ���ʵ����
assign Temp_Metric = (Survivor)? ADD1: ADD0; //Survivor=1��Temp_Metric=ADD1;Survivor=0,Temp_Metric=ADD0
assign Metric = (CompareEnable)? Temp_Metric:ADD0;//CompareEnable=1,Metric=Temp_Metric;CompareEnable=0,Metric=ADD0
endmodule


/*-----------------------------------*/
module COMPARATOR (CompareEnable, Metric1, Metric0, Survivor);
//
// 2's complement comparator to find which is the smaller between Metric1 and Metric0.
// 2 �Ĳ���Ƚ������ҳ� Metric1 �� Metric0 ֮��Ľ�Сֵ
// Survivor : 1 --> Metric1 is the smaller one. Metric1 ��С
// 0 --> Metric0 is the smaller one. 
/*-----------------------------------*/
//input��output�˿�����
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
assign M1msb_xor_M0msb = M1msb ^ M0msb;// Metric0��Metric1�����λ���64λ���������λʼ��Ϊ0
assign M1unsignedcompM0 = (M1unsigned > M0unsigned)? 0:1;// Metric0>Metric1, M1unsignedcompM0=0;Metric0<Metric1, M1unsignedcompM0=1
assign Survivor = (CompareEnable) ?M1msb_xor_M0msb ^ M1unsignedcompM0:'b0;//CompareEnable=1,Survivor=M1msb_xor_M0msb;CompareEnable=0,Survivor=M1unsignedcompM0
endmodule


/*-----------------------------------*/
module LOWESTPICK (Reset, Active, Hold, Init, Clock1, Clock2, ACSSegment,
Metric3, Metric2, Metric1, Metric0, LowestMetric, LowestState);
//
// This module is used to find which of 256 states has the smallest metric. //��ģ�����ڲ��� 256 ��״̬�о�����С������״̬��
//��������(X)��������Ͷ���ֵӦΪ 0) 
/*-----------------------------------*/
//input��output�˿�����
input Reset, Active, Clock1, Clock2, Hold, Init;
input [`WD_FSM-1:0] ACSSegment;
input [`WD_METR-1:0] Metric3, Metric2, Metric1, Metric0;
output [`WD_METR-1:0] LowestMetric;
output [`WD_STATE-1:0] LowestState;

//��������
reg [`WD_METR-1:0] LowestMetric, Reg_Metric; 
reg [`WD_STATE-1:0] LowestState, Reg_State;
wire [`WD_METR-1:0] MetricCompareResult; 
wire [`WD_STATE-1:0] StateCompareResult;
wire [`WD_METR-1:0] Lowest_Metric4; //����4������еĴ����С���
wire [`WD_STATE-1:0] Lowest_State4; //����4������еĴ����С����

// find state with the lowest metrics for current input 
// �ҵ���ǰ�������Ͷ�����״̬
LOWEST_OF_FOUR lowof4 (.Active(Active), .ACSSegment(ACSSegment), .Metric3(Metric3), .Metric2(Metric2),
		.Metric1(Metric1), .Metric0(Metric0),.Lowest_State4(Lowest_State4), .Lowest_Metric4(Lowest_Metric4));

// compare the 'previous lowest metric' with the'lowest metric of current input'
// ������ǰ��Ͷ������롰��ǰ�������Ͷ��������бȽ�
COMPARATOR comp (.CompareEnable(Active), .Metric1(Reg_Metric), .Metric0(Lowest_Metric4), .Survivor(CompareBit));
assign MetricCompareResult = (CompareBit) ? Reg_Metric:Lowest_Metric4; //CompareBit=1,MetricCompareResult=Reg_Metric;CompareBit=0,MetricCompareResult=Lowest_Metric4
assign StateCompareResult = (CompareBit) ? Reg_State:Lowest_State4; //CompareBit=1,StateCompareResult=Reg_State;CompareBit=0,StateCompareResult=Lowest_State4
 
always @(negedge Clock2 or negedge Reset)//��Clock2����Reset�½���ʱִ��
begin
if (~Reset) begin //Reset=0
  Reg_Metric <=0;
  Reg_State <= 0; 
  end
else if (Active) begin
  if (Init) 
	  begin
		Reg_Metric <= Lowest_Metric4;
		Reg_State <= Lowest_State4;//��ʼ��ʱ����ǰ������Ͷ�����״̬��ֵ��֮ǰ����Ͷ�����״̬
	  end
  else 
	  begin
		Reg_Metric <= MetricCompareResult;
		Reg_State <= StateCompareResult;  //���ȽϽ����ֵ��֮ǰ��������Ⱥ�״̬
	  end
end end

always @(negedge Clock1 or negedge Reset) //Clock1����Reset���½���ʱִ�����
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
// ��ģ���������ĸ��������ҵ�һ��״̬������ÿ�������м�����������С������
/*-----------------------------------*/
//input��output�˿�����
input Active;
input [`WD_FSM-1:0] ACSSegment;
input [`WD_METR-1:0] Metric3, Metric2, Metric1, Metric0;
output [`WD_STATE-1:0] Lowest_State4; output [`WD_METR-1:0] Lowest_Metric4;
wire Surv1, Surv2, Surv3, Bit_One;
wire [`WD_METR-1:0] MetricX, MetricY;

COMPARATOR comp1 (.CompareEnable(Active), .Metric1(Metric1), .Metric0(Metric0), .Survivor(Surv1)); // �Ƚ�metric1��Metric0
COMPARATOR comp2 (.CompareEnable(Active), .Metric1(Metric3), .Metric0(Metric2), .Survivor(Surv2)); // �Ƚ�metric3��metric2
assign MetricX = (Surv1)?Metric1:Metric0;// ��Metric1��Metric0�н�С��ֵ����MetricX 
assign MetricY = (Surv2)?Metric3:Metric2;// ��Metric3��Metric2�н�С��ֵ����MetricY

COMPARATOR comp3 (.CompareEnable(Active), .Metric1(MetricY), .Metric0(MetricX), .Survivor(Surv3));// �Ƚ� MetricY ��MetricX.
assign Lowest_State4 = {ACSSegment, Surv3, Bit_One};//����С��������״̬
assign Lowest_Metric4 = (Surv3)?MetricY:MetricX;//������С����
endmodule