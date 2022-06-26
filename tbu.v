`include "params.v"
/*-----------------------------------*/
// Module: TBU
// File : tbu.v
// Description : Description of TBU Unit in Viterbi Decoder 
// Simulator : Modelsim 6.5 / Windows 7/10 
/*-----------------------------------*/
// Revision Number : 1
// Description : Initial Design 
/*-----------------------------------*/

module TBU (Reset, Clock1, Clock2, TB_EN, Init, Hold, InitState, DecodedData, DataTB, AddressTB);

 //reset信号用于清空
 //Clock1 为四分频信号
 //Clock2 为四分频信号

input Reset, Clock1, Clock2, Init, Hold;
 //HOLD:为1码信号（解码器输入）指示过程结束。确定解码结束
 //Init指示1码信号（解码器输入）的过程开始。确定解码开始
input [`WD_STATE-1:0] InitState; //初始化状态8位[7:0]
input TB_EN;//TB_EN：当ACSPages数目达到63时候开始进行路径回溯
input [`WD_RAM_DATA-1:0] DataTB;
output [`WD_RAM_ADDRESS-`WD_FSM-1:0] AddressTB;//数据总线宽度为WD_RAM_DATA =8， DataTB 8位 [7:0]
output DecodedData;//输出解码数据
wire [`WD_STATE-1:0] OutStateTB;//OutStateTB 8位
TRACEUNIT tb (Reset, Clock1, Clock2, TB_EN, InitState, Init, Hold, DataTB, AddressTB, OutStateTB);//调用traceunit路径回溯模块
assign DecodedData = OutStateTB [`WD_STATE-1];
endmodule
/*-----------------------------------*/
module TRACEUNIT (Reset, Clock1, Clock2, Enable, InitState, Init, Hold,Survivor, AddressTB, OutState); //真正的路径回溯模块
/*-----------------------------------*/
input Reset, Clock1, Clock2, Enable;
//Clock1/Clock2
//时钟2超前时钟1四分之一个周期
//时钟1被控制单元用作更新加比选模块，更新BMG分支度量和加选比的输出，时钟2被用作判断什么时候把地址放入地址总线里。
input [`WD_STATE-1:0] InitState;
input Init, Hold;
input [`WD_RAM_DATA-1:0] Survivor;
output [`WD_STATE-1:0] OutState;
output [`WD_RAM_ADDRESS-`WD_FSM-1:0] AddressTB;
reg [`WD_STATE-1:0] CurrentState; 
reg [`WD_STATE-1:0] NextState; 
reg [`WD_STATE-1:0] OutState;
wire SurvivorBit;
always @(negedge Clock1 or negedge Reset) //当时钟Clock1四分频时钟下降沿或者reset下降沿出现时
  begin
if (~Reset) begin//如果RESET=0，恢复初始0状态
CurrentState <=0; OutState <=0;
end
else if (Enable)//如果使能信号有效
begin
if (Init) CurrentState <= InitState;
else CurrentState <= NextState;
if (Hold) OutState <= NextState; end
end
assign AddressTB = CurrentState [`WD_STATE-1:`WD_STATE-5];
always @(negedge Clock2 or negedge Reset) begin
if (~Reset) NextState <= 0; else
if (Enable) NextState <= {CurrentState [`WD_STATE-2:0],SurvivorBit}; end
assign SurvivorBit =
(Clock1 && Clock2 && ~Init) ? Survivor [CurrentState [2:0]]:'bz;
endmodule