/******************************************************/ 
// @brief: 
// @copyright: 
// @license: 
// @birth: created by xcz on 2022.6.15
// @version: 
// @revision: last revised by xcz on 2022.6.15
/******************************************************/ 
module pDFF(DATA,QOUT,CLOCK,RESET);
//  D类型触发器
parameter WIDTH = 1;
input [WIDTH-1:0] DATA;
input CLOCK, RESET;
output [WIDTH-1:0] QOUT;
reg [WIDTH-1:0] QOUT;


always @(posedge CLOCK or negedge RESET)
begin
if (~RESET) 
//dff状态切换
    QOUT <= 0; //复位时赋0
else
    QOUT <= DATA; //输出DATA
end
endmodule