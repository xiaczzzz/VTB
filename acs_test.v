`include "params.v"
`timescale 1 ns/ 1 ns
module acs_test();
	reg Reset;
	reg Clock1;
	reg Clock2;
	reg Active;
	reg Init;
	reg Hold;
	reg CompareStart;
	reg [5:0] ACSSegment;
	reg [15:0] Distance;
	reg [63:0] MMPathMetric;
	wire [7:0] LowestState;
	wire [4:0] MMReadAddress;
	wire [5:0] MMWriteAddress;
	wire MMBlockSelect;
	wire [31:0] MMMetric;
	wire [3:0] Survivors;

	reg CLOCK;//控制信号设置
	reg count;
	wire EVENT_1,EVENT_0;
    reg [`WD_DEPTH-1:0] ACSPage;

	initial CLOCK = 0; 
   always #(`HALF/2) CLOCK = ~CLOCK; //建立时钟信号，时钟周期是100ns，频率10MHz
	
    //Reset,Active
	initial begin
    Reset=1;Active=0;
	#200 Reset=0;Active=0;//复位
	#300 Reset=1; Active=1;
	end
//CompareStart
      initial begin
     CompareStart=0;
     #750 
     CompareStart=1;
     end
     
// Clock1 and Clock2
   always @(posedge CLOCK or negedge Reset) 
      if (~Reset) count <= 0; else count <= ~count;
   always @(posedge CLOCK or negedge Reset) 
   begin 
      if (~Reset) 
        begin
           Clock1 <= 0; 
           Clock2 <= 0;
        end
      else
        begin
          if (count) Clock1 <=~Clock1;
          if (~count) Clock2 <= ~Clock2;
        end
   end
//ACSPage,ACSSegment的递增，Hold, Init信号的设置
   assign EVENT_1 = (ACSSegment == 6'h3E); //11_1110
   assign EVENT_0 = (ACSSegment == 6'h3F); //11_1111
    
   always @(posedge Clock1 or negedge Reset)//在Clock1的上升沿
   begin
     if (~Reset) 
        begin
           {ACSPage,ACSSegment} <= 12'hFFF; //1111_1111_1111
           Init <=0;
           Hold <= 0;
        end     
     else if (Active) 
          begin
             // 增加ACSPage和ACSSegment
             {ACSPage,ACSSegment} <= {ACSPage,ACSSegment} + 1;
                    
             //Hold信号标志着一个码元处理的结束，发生在ACSSegment=3EH的时候
             if (EVENT_1) begin Init <= 0; Hold <= 1; end 
             //Init信号标志着一个码元处理的开始，发生在ACSSegment=3F的时候
              else if (EVENT_0) begin Init <= 1; Hold <= 0; end 
                    else begin {Init,Hold} <= 0; end
        end
   end

     
//设置BMG输入的Distance信号；和RAM里面的 metricmemory输入的MMPathMetric信号
    always @( ACSSegment )
	begin
		case(ACSSegment)
		0:begin  Distance=16'b0010_0101_1000_0101; //0 2 1 1 2 0 1 1 ;8525
			 MMPathMetric=64'h0000_0000_0000_0000; 
		  end        
		1:begin  Distance=16'b1000_1000_0100_0100;  //2 0 2 0 1 0 1 0
			 MMPathMetric=64'h0102_0304_0b0c_0d0e;  //1 2 3 4 b c d e
		  end     
		2:begin 
			Distance=16'b1010_0110_0001_0100;  
			MMPathMetric=64'h0000_0000_0000_0000; 
		  end
		3: begin
			Distance=16'b1000_0100_0110_0001;  
			 MMPathMetric=64'h0000_0000_0000_0000;
		  end
		4:begin 
			Distance=16'b0101_0101_1010_0100;  
			 MMPathMetric=64'h0f03_0e0a_0b01_0204;
		  end
         default:begin 
			Distance=16'b0000_0000_0000_0000;  
			 MMPathMetric=64'h0000_0000_0000_0000;
		  end    
		endcase	
				
	end

//实例化
ACSUNIT acsunit1(.Reset(Reset), .Clock1(Clock1), .Clock2(Clock2), .Active(Active), .Init(Init), .Hold(Hold),
		 .CompareStart(CompareStart), 
  		  .ACSSegment(ACSSegment), .Distance(Distance), .Survivors(Survivors),  .LowestState(LowestState),
                  .MMReadAddress(MMReadAddress), .MMWriteAddress(MMWriteAddress), .MMBlockSelect(MMBlockSelect), 
		.MMMetric(MMMetric), 
                  .MMPathMetric(MMPathMetric));   

endmodule    