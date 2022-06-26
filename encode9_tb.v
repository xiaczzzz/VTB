`include "params.v"

`timescale 1ns/1ns

`define DELAY 20

/******************************************************/ 
// @brief: 
// @copyright: 
// @license: 
// @birth: created by xcz on 2022.6.15
// @version: 
// @revision: last revised by xcz on 2022.6.15
/******************************************************/ 

module encode9_tb();
    reg clk;
    reg reset;
    reg data_in;
    wire [1:0] data_out;
    wire [8:0] wA, wB, Sh_Reg;

    viterbi_encode9 ve1
    (
        .X(data_in),
        .Clock(clk),
        .Reset(reset),
        .Y(data_out),
        .wA(wA),
        .wB(wB),
        .ShReg(Sh_Reg)
    );

    initial clk = 1'b0;
    always #(`DELAY/2) clk = ~clk;

    initial begin
        reset = 1'b0;
        #(`DELAY*3)
        reset = 1'b1;
    end

    initial begin
        $timeformat(-9,1,"ns",6);
    end

    task expect;
    input [1:0] answer;
        begin
        if( data_out !== answer)
            begin
                $display("time %t: answer should be %b while out was %b",
                $time, answer, data_out);
                $display("test failed");
                $stop;
            end
        end
    endtask

    initial begin
        data_in = 1'b0; #(`DELAY*4) expect(2'b00);
        data_in = 1'b1; #(`DELAY) expect(2'b11);
        data_in = 1'b0; #(`DELAY) expect(2'b10);
        data_in = 1'b1; #(`DELAY) expect(2'b11);
        data_in = 1'b0; #(`DELAY) expect(2'b00);
        data_in = 1'b0; #(`DELAY) expect(2'b01);
        data_in = 1'b0; #(`DELAY) expect(2'b01);
        data_in = 1'b1; #(`DELAY) expect(2'b01);
        data_in = 1'b0; #(`DELAY) expect(2'b11); 
        data_in = 1'b1; #(`DELAY) expect(2'b11);
        data_in = 1'b1; #(`DELAY) expect(2'b01);
        data_in = 1'b0; #(`DELAY) expect(2'b00);
        data_in = 1'b1; #(`DELAY) expect(2'b10);

        $display("test passed");
    end

endmodule
