`include "params.v" 
/********************************************************************* 
RAMEnable:ram????
AddressRAM:ram????
DataRAM:ram????
RWSelect:?/???????
ReadClock:????????
WriteClock:????????
*********************************************************************/
module RAM (RAMEnable, AddressRAM, DataRAM,
		RWSelect, ReadClock, WriteClock);	//survivor memory instantiation

input RAMEnable, RWSelect, ReadClock, WriteClock;
input [`WD_RAM_ADDRESS-1:0] AddressRAM; //???????????11
input [`WD_RAM_DATA-1:0] DataRAM; //8

//????RAMMODULE?????????????
RAMMODULE #(2048,8,11) ram (._Enable(RAMEnable), .Data(DataRAM), .Address(AddressRAM), 
				.RWSelect(RWSelect), .RClock(ReadClock), .WClock(WriteClock));
endmodule

/********************************************************************
_Enable:????
 Data:????
 Address:????
 RWSelect:?/???????
 RClock:????????
 WClock:????????

RAMMODULE?????????ACS???????????suvivors????????????TBU????
MMU??????????
*********************************************************************/ 
module RAMMODULE (_Enable, Data, Address, RWSelect, RClock, WClock);
//??
parameter SIZE = 2048; 
parameter DATABITS = 8;
parameter ADDRESSBITS = 7;
//??
input [DATABITS-1:0] Data;
input [ADDRESSBITS-1:0] Address;
input RWSelect;  
input RClock,WClock,_Enable;

reg [DATABITS-1:0] Data_Regs [SIZE-1:0]; //2k?8????Data_Regs
reg [DATABITS-1:0] DataBuff;//8????DataBuff????????????Address????

always @(negedge WClock) begin//??WClock??????????????Data??Data_Regs
if (~_Enable) Data_Regs [Address] <= Data; end//?????

always @(negedge RClock) begin//??RClock???????,??????????Address???Data_Regs???????????DataBuff?
if (~_Enable) DataBuff <= Data_Regs [Address]; end//?????
assign Data = (RWSelect) ? DataBuff:'bz;//??????RWSelect????????DataBuff???????Data
endmodule

/*-----------------------------------*/
module METRICMEMORY (Reset, Clock1, Active, MMReadAddress,
			MMWriteAddress, MMBlockSelect, MMMetric, MMPathMetric);
//METRICMEMORY???????????????
//???????????????????????????
//????????????????
//Reset, ????
//Clock1, ????
//Active, ??????MMMetric??????????
//MMReadAddress,???????????
//MMWriteAddress,???????????
//MMBlockSelect,??????????
//MMMetric, ????????????????
//MMPathMetric,???
// This module is used as metric memory who holds the metric values. 
/*-----------------------------------*/
input Reset, Clock1, Active, MMBlockSelect; 
input [`WD_METR*`N_ACS-1:0] MMMetric; //8*4
input [`WD_FSM-1:0] MMWriteAddress; //5
input [`WD_FSM-2:0] MMReadAddress;//4
output [`WD_METR*2*`N_ACS-1:0] MMPathMetric;//8*2*4

reg [`WD_METR*`N_ACS-1:0] M_REG_A [`N_ITER-1:0]; //64?8*4????M_REG_A
reg [`WD_METR*`N_ACS-1:0] M_REG_B [`N_ITER-1:0]; //64?8*4????M_REG_B
reg [`WD_METR*2*`N_ACS-1:0] MMPathMetric;//8*2*4

always @(negedge Clock1 or negedge Reset) begin//??clock1?????reset??????
if (~Reset)//??????????
begin //?????M_REG_A?M_REG_B
M_REG_A [63] <= 0;M_REG_A [62] <= 0;M_REG_A [61] <= 0;
M_REG_A [60] <= 0;M_REG_A [59] <= 0;M_REG_A [58] <= 0;
M_REG_A [57] <= 0;M_REG_A [56] <= 0;M_REG_A [55] <= 0;
M_REG_A [54] <= 0;M_REG_A [53] <= 0;M_REG_A [52] <= 0;
M_REG_A [51] <= 0;M_REG_A [50] <= 0;M_REG_A [49] <= 0;
M_REG_A [48] <= 0;M_REG_A [47] <= 0;M_REG_A [46] <= 0;
M_REG_A [45] <= 0;M_REG_A [44] <= 0;M_REG_A [43] <= 0; 
M_REG_A [42] <= 0;M_REG_A [41] <= 0;M_REG_A [40] <= 0;
M_REG_A [39] <= 0;M_REG_A [38] <= 0;M_REG_A [37] <= 0;
M_REG_A [36] <= 0;M_REG_A [35] <= 0;M_REG_A [34] <= 0;
M_REG_A [33] <= 0;M_REG_A [32] <= 0;M_REG_A [31] <= 0;
M_REG_A [30] <= 0;M_REG_A [29] <= 0;M_REG_A [28] <= 0; 
M_REG_A [27] <= 0;M_REG_A [26] <= 0;M_REG_A [25] <= 0;
M_REG_A [24] <= 0;M_REG_A [23] <= 0;M_REG_A [22] <= 0;
M_REG_A [21] <= 0;M_REG_A [20] <= 0;M_REG_A [19] <= 0;
M_REG_A [18] <= 0;M_REG_A [17] <= 0;M_REG_A [16] <= 0;
M_REG_A [15] <= 0;M_REG_A [14] <= 0;M_REG_A [13] <= 0; 
M_REG_A [12] <= 0;M_REG_A [11] <= 0;M_REG_A [10] <= 0;
M_REG_A [9] <= 0 ;M_REG_A [8] <= 0 ;M_REG_A [7] <= 0;
M_REG_A [6] <= 0 ;M_REG_A [5] <= 0 ;M_REG_A [4] <= 0;
M_REG_A [3] <= 0 ;M_REG_A [2] <= 0 ;M_REG_A [1] <= 0;
M_REG_A [0] <= 0;
 
M_REG_B [63] <= 0;M_REG_B [62] <= 0;M_REG_B [61] <= 0; 
M_REG_B [60] <= 0;M_REG_B [59] <= 0;M_REG_B [58] <= 0; 
M_REG_B [57] <= 0;M_REG_B [56] <= 0;M_REG_B [55] <= 0;
M_REG_B [54] <= 0;M_REG_B [53] <= 0;M_REG_B [52] <= 0;
M_REG_B [51] <= 0;M_REG_B [50] <= 0;M_REG_B [49] <= 0;
M_REG_B [48] <= 0;M_REG_B [47] <= 0;M_REG_B [46] <= 0;
M_REG_B [45] <= 0;M_REG_B [44] <= 0;M_REG_B [43] <= 0; 
M_REG_B [42] <= 0;M_REG_B [41] <= 0;M_REG_B [40] <= 0;
M_REG_B [39] <= 0;M_REG_B [38] <= 0;M_REG_B [37] <= 0;
M_REG_B [36] <= 0;M_REG_B [35] <= 0;M_REG_B [34] <= 0;
M_REG_B [33] <= 0;M_REG_B [32] <= 0;M_REG_B [31] <= 0;
M_REG_B [30] <= 0;M_REG_B [29] <= 0;M_REG_B [28] <= 0; 
M_REG_B [27] <= 0;M_REG_B [26] <= 0;M_REG_B [25] <= 0;
M_REG_B [24] <= 0;M_REG_B [23] <= 0;M_REG_B [22] <= 0;
M_REG_B [21] <= 0;M_REG_B [20] <= 0;M_REG_B [19] <= 0;
M_REG_B [18] <= 0;M_REG_B [17] <= 0;M_REG_B [16] <= 0;
M_REG_B [15] <= 0;M_REG_B [14] <= 0;M_REG_B [13] <= 0; 
M_REG_B [12] <= 0;M_REG_B [11] <= 0;M_REG_B [10] <= 0;
M_REG_B [9] <= 0 ;M_REG_B [8] <= 0 ;M_REG_B [7] <= 0;
M_REG_B [6] <= 0 ;M_REG_B [5] <= 0 ;M_REG_B [4] <= 0;
M_REG_B [3] <= 0 ;M_REG_B [2] <= 0 ;M_REG_B [1] <= 0;
M_REG_B [0] <= 0; 
end
else 	begin//?????????
	if (Active)//?active??????MMMetric??????????
		case (MMBlockSelect)
		  0 : M_REG_A [MMWriteAddress] <= MMMetric; //?MMBlockSelect=0????A???
		  1 : M_REG_B [MMWriteAddress] <= MMMetric; //?MMBlockSelect=1????B???
		endcase 
	end
end

always @(MMReadAddress or Reset) //???????????????????????
  begin
if (~Reset) MMPathMetric <=0; //??reset???????MMPathMetric?0
else begin//??reset???????
case (MMBlockSelect)//?0???B??1???A????????????????????
0 : case (MMReadAddress)//???????????MMReadAddress?M_REG_B[MMReadAddress]?M_REG_B[MMReadAddress+1]????MMPathMetric????ACS??
	0 : MMPathMetric <= {M_REG_B [1],M_REG_B[0]};
	1 : MMPathMetric <= {M_REG_B [3],M_REG_B[2]};
	2 : MMPathMetric <= {M_REG_B [5],M_REG_B[4]};
	3 : MMPathMetric <= {M_REG_B [7],M_REG_B[6]};
	4 : MMPathMetric <= {M_REG_B [9],M_REG_B[8]};
	5 : MMPathMetric <= {M_REG_B [11],M_REG_B[10]}; 
	6 : MMPathMetric <= {M_REG_B [13],M_REG_B[12]}; 
	7 : MMPathMetric <= {M_REG_B [15],M_REG_B[14]};
	8 : MMPathMetric <= {M_REG_B [17],M_REG_B[16]};
	9 : MMPathMetric <= {M_REG_B [19],M_REG_B[18]}; 
	10 : MMPathMetric <= {M_REG_B [21],M_REG_B[20]}; 
	11 : MMPathMetric <= {M_REG_B [23],M_REG_B[22]};
	12 : MMPathMetric <= {M_REG_B [25],M_REG_B[24]}; 
	13 : MMPathMetric <= {M_REG_B [27],M_REG_B[26]}; 
	14 : MMPathMetric <= {M_REG_B [29],M_REG_B[28]}; 
	15 : MMPathMetric <= {M_REG_B [31],M_REG_B[30]};
	16 : MMPathMetric <= {M_REG_B [33],M_REG_B[32]}; 
	17 : MMPathMetric <= {M_REG_B [35],M_REG_B[34]}; 
	18 : MMPathMetric <= {M_REG_B [37],M_REG_B[36]};
	19 : MMPathMetric <= {M_REG_B [39],M_REG_B[38]}; 
	20 : MMPathMetric <= {M_REG_B [41],M_REG_B[40]}; 
	21 : MMPathMetric <= {M_REG_B [43],M_REG_B[42]}; 
	22 : MMPathMetric <= {M_REG_B [45],M_REG_B[44]}; 
	23 : MMPathMetric <= {M_REG_B [47],M_REG_B[46]};
	24 : MMPathMetric <= {M_REG_B [49],M_REG_B[48]}; 
	25 : MMPathMetric <= {M_REG_B [51],M_REG_B[50]}; 
	26 : MMPathMetric <= {M_REG_B [53],M_REG_B[52]}; 
	27 : MMPathMetric <= {M_REG_B [55],M_REG_B[54]}; 
	28 : MMPathMetric <= {M_REG_B [57],M_REG_B[56]}; 
	29 : MMPathMetric <= {M_REG_B [59],M_REG_B[58]}; 
	30 : MMPathMetric <= {M_REG_B [61],M_REG_B[60]}; 
	31 : MMPathMetric <= {M_REG_B [63],M_REG_B[62]};
	endcase
1 : case (MMReadAddress)
	0 : MMPathMetric <= {M_REG_A [1],M_REG_A[0]};
	1 : MMPathMetric <= {M_REG_A [3],M_REG_A[2]};
	2 : MMPathMetric <= {M_REG_A [5],M_REG_A[4]};
	3 : MMPathMetric <= {M_REG_A [7],M_REG_A[6]};
	4 : MMPathMetric <= {M_REG_A [9],M_REG_A[8]};
	5 : MMPathMetric <= {M_REG_A [11],M_REG_A[10]}; 
	6 : MMPathMetric <= {M_REG_A [13],M_REG_A[12]}; 
	7 : MMPathMetric <= {M_REG_A [15],M_REG_A[14]};
	8 : MMPathMetric <= {M_REG_A [17],M_REG_A[16]};
	9 : MMPathMetric <= {M_REG_A [19],M_REG_A[18]}; 
	10 : MMPathMetric <= {M_REG_A [21],M_REG_A[20]}; 
	11 : MMPathMetric <= {M_REG_A [23],M_REG_A[22]}; 
	12 : MMPathMetric <= {M_REG_A [25],M_REG_A[24]}; 
	13 : MMPathMetric <= {M_REG_A [27],M_REG_A[26]}; 
	14 : MMPathMetric <= {M_REG_A [29],M_REG_A[28]}; 
	15 : MMPathMetric <= {M_REG_A [31],M_REG_A[30]};
	16 : MMPathMetric <= {M_REG_A [33],M_REG_A[32]};
	17 : MMPathMetric <= {M_REG_A [35],M_REG_A[34]}; 
	18 : MMPathMetric <= {M_REG_A [37],M_REG_A[36]}; 
	19 : MMPathMetric <= {M_REG_A [39],M_REG_A[38]}; 
	20 : MMPathMetric <= {M_REG_A [41],M_REG_A[40]}; 
	21 : MMPathMetric <= {M_REG_A [43],M_REG_A[42]};
	22 : MMPathMetric <= {M_REG_A [45],M_REG_A[44]}; 
	23 : MMPathMetric <= {M_REG_A [47],M_REG_A[46]};
	24 : MMPathMetric <= {M_REG_A [49],M_REG_A[48]}; 
	25 : MMPathMetric <= {M_REG_A [51],M_REG_A[50]};
	26 : MMPathMetric <= {M_REG_A [53],M_REG_A[52]}; 
	27 : MMPathMetric <= {M_REG_A [55],M_REG_A[54]}; 
	28 : MMPathMetric <= {M_REG_A [57],M_REG_A[56]}; 
	29 : MMPathMetric <= {M_REG_A [59],M_REG_A[58]}; 
	30 : MMPathMetric <= {M_REG_A [61],M_REG_A[60]}; 
	31 : MMPathMetric <= {M_REG_A [63],M_REG_A[62]};
	endcase endcase
end
end
endmodule