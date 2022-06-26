//decoder.v

`include "params.v"
/*-----------------------------------*/
// Module: VITERBIDECODER
// File : decoder.v
// Description : Top Level Module of Viterbi Decoder 
// Simulator : Modelsim 10.5 / Windows 10/11
/*-----------------------------------*/
// Revision Number : 1
// Description : Initial Design 
/*-----------------------------------*/

module VITERBIDECODER (Reset, CLOCK, Active, Code, DecodeOut); 
input Reset, CLOCK, Active; 
input [`WD_CODE-1:0] Code;
output DecodeOut;
wire [`WD_DIST*2*`N_ACS-1:0] Distance;
wire [`WD_FSM-1:0] ACSSegment; 
wire [`WD_DEPTH-1:0] ACSPage;
wire CompareStart, Hold, Init;
wire [`N_ACS-1:0] Survivors; 
wire [`WD_STATE-1:0] LowestState;
wire TB_EN;
wire RAMEnable;
wire ReadClock, WriteClock, RWSelect;
wire [`WD_RAM_ADDRESS-1:0] AddressRAM; 
wire [`WD_RAM_DATA-1:0] DataRAM;
wire [`WD_RAM_DATA-1:0] DataTB;
wire [`WD_RAM_ADDRESS-`WD_FSM-1:0] AddressTB;
wire Clock1, Clock2;
wire [`WD_METR*2*`N_ACS-1:0] MMPathMetric; 
wire [`WD_METR*`N_ACS-1:0] MMMetric;
wire [`WD_FSM-2:0] MMReadAddress;
wire [`WD_FSM-1:0] MMWriteAddress;
wire MMBlockSelect;
//Viterbi译码器模块的实例化
CONTROL ctl (Reset, CLOCK, Clock1, Clock2, ACSPage, ACSSegment,Active, CompareStart, Hold, Init, TB_EN);
BMG bmg (Reset, Clock2, ACSSegment, Code, Distance);
ACSUNIT acs (Reset, Clock1, Clock2, Active, Init, Hold, CompareStart, ACSSegment, Distance, Survivors, LowestState,
MMReadAddress, MMWriteAddress, MMBlockSelect, MMMetric, MMPathMetric);
  MMU mmu (CLOCK, Clock1, Clock2, Reset, Active, Hold, Init, ACSPage, ACSSegment [`WD_FSM-1:1],Survivors,DataTB,AddressTB,RWSelect,ReadClock,WriteClock,RAMEnable, AddressRAM, DataRAM);
TBU tbu (Reset, Clock1, Clock2, TB_EN, Init, Hold, LowestState, DecodeOut, DataTB, AddressTB);
METRICMEMORY mm (Reset, Clock1, Active, MMReadAddress, MMWriteAddress, MMBlockSelect, MMMetric, MMPathMetric);
RAM ram (RAMEnable, AddressRAM, DataRAM, RWSelect, ReadClock, WriteClock);
endmodule