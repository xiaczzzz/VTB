`include "params.v" 
`define D_PER
/****************************************************************************** ******/
module VD();
    reg CLOCK;
    initial CLOCK = 0;
    always #(`HALF/2) CLOCK = ~CLOCK;
    
    reg Reset; 
    reg DRESET;
    initial begin 
        DRESET = 1;
        Reset = 1;
        #200 Reset = 0;DRESET=0;
        #300 Reset = 1;
        DRESET = 1;
    end

    reg X;
    wire [`WD_CODE-1:0] Code; 
    initial X = 0;
    initial begin
        #475 X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0;
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0;
        #`DPERIOD X = 0; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1;
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0;
        #`DPERIOD X = 0; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 0;
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1;
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0;
        #`DPERIOD X = 0; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 0;
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0;
        #`DPERIOD X = 0; 
        #`DPERIOD X = 0;
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1;
        #`DPERIOD X = 0; 
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 1;
        #`DPERIOD X = 0; 
        #`DPERIOD X = 1; 
        #`DPERIOD X = 0;
    end

    reg D_CLOCK;
    initial D_CLOCK = 0;
    always #(`DPERIOD/2) D_CLOCK <= ~D_CLOCK;
    //???????????? X

    viterbi_encode9 enc(X,Code,D_CLOCK,DRESET);
        reg Active;
        always @(Code or Reset) //
            if (~Reset) Active <= 0;    // a simple data input synchronizer 
                                    //????????????????????????????????????
            else if (Code!=0) Active <= 1;
                                    // Active should come from synch module in 'real' application.
                                    //active ???????????????real??????????????????????????????
    
        wire DecodeOut;

    VITERBIDECODER vd (Reset, CLOCK, Active, Code, DecodeOut); 

endmodule

module VD_err();
    reg CLOCK;
    initial CLOCK = 0;
    always #(`HALF/2) CLOCK = ~CLOCK;

    reg Reset;

    initial begin 
        Reset = 1;
        #200 Reset = 0;
        #300 Reset = 1; 
    end

    reg [`WD_CODE-1:0] CorrectCode;

    initial CorrectCode = 2'b00;

    initial begin
        #475 CorrectCode = 2'b11; 
        #`DPERIOD CorrectCode = 2'b10; 
        #`DPERIOD CorrectCode = 2'b11; 
        #`DPERIOD CorrectCode = 2'b00; 
        #`DPERIOD CorrectCode = 2'b10;

    //2
        #`DPERIOD CorrectCode = 2'b11; 
        #`DPERIOD CorrectCode = 2'b01; 
        #`DPERIOD CorrectCode = 2'b01; 
        #`DPERIOD CorrectCode = 2'b10; 
        #`DPERIOD CorrectCode = 2'b01;

    //3
        #`DPERIOD CorrectCode = 2'b10; 
        #`DPERIOD CorrectCode = 2'b10; 
        #`DPERIOD CorrectCode = 2'b00; 
        #`DPERIOD CorrectCode = 2'b10; 
        #`DPERIOD CorrectCode = 2'b10;

    //4
        #`DPERIOD CorrectCode = 2'b00; 
        #`DPERIOD CorrectCode = 2'b00; 
        #`DPERIOD CorrectCode = 2'b01; 
        #`DPERIOD CorrectCode = 2'b00; 
        #`DPERIOD CorrectCode = 2'b01;

    //5
        #`DPERIOD CorrectCode = 2'b01; //2'b01 
        #`DPERIOD CorrectCode = 2'b11; //2'b11 
        #`DPERIOD CorrectCode = 2'b00; //2'b00 
        #`DPERIOD CorrectCode = 2'b00; //2'b00 
        #`DPERIOD CorrectCode = 2'b10; //2'b10

    //6
        #`DPERIOD CorrectCode = 2'b11; //2'b11 
        #`DPERIOD CorrectCode = 2'b01; //2'b01 
        #`DPERIOD CorrectCode = 2'b01; //2'b01 
        #`DPERIOD CorrectCode = 2'b10; //2'b10 
        #`DPERIOD CorrectCode = 2'b01; //2'b01

    //7
        #`DPERIOD CorrectCode = 2'b10; //2'b10 
        #`DPERIOD CorrectCode = 2'b10; //2'b10 
        #`DPERIOD CorrectCode = 2'b00; //2'b00 
        #`DPERIOD CorrectCode = 2'b10; //2'b10 
        #`DPERIOD CorrectCode = 2'b10; //2'b10

    //8
        #`DPERIOD CorrectCode = 2'b00; //2'b00 
        #`DPERIOD CorrectCode = 2'b00; //2'b00 
        #`DPERIOD CorrectCode = 2'b01; //2'b01 
        #`DPERIOD CorrectCode = 2'b00; //2'b00 
        #`DPERIOD CorrectCode = 2'b01; //2'b01

    //9
        #`DPERIOD CorrectCode = 2'b01; //2'b01 
        #`DPERIOD CorrectCode = 2'b11; //2'b11 
        #`DPERIOD CorrectCode = 2'b00; //2'b00 
        #`DPERIOD CorrectCode = 2'b00; //2'b00 
        #`DPERIOD CorrectCode = 2'b10; //2'b10

    //10
        #`DPERIOD CorrectCode = 2'b11; //2'b11 
        #`DPERIOD CorrectCode = 2'b01; //2'b01 
        #`DPERIOD CorrectCode = 2'b01; //2'b01 
        #`DPERIOD CorrectCode = 2'b10; //2'b10 
        #`DPERIOD CorrectCode = 2'b01; //2'b01
        
    //11
        #`DPERIOD CorrectCode = 2'b01; //2'b01 
        #`DPERIOD CorrectCode = 2'b11; //2'b11 
        #`DPERIOD CorrectCode = 2'b01; //2'b01 
        #`DPERIOD CorrectCode = 2'b01; //2'b01 
        #`DPERIOD CorrectCode = 2'b00; //2'b00
        
    //12
        #`DPERIOD CorrectCode = 2'b10; //2'b10 
        #`DPERIOD CorrectCode = 2'b11; //2'b11
        #`DPERIOD CorrectCode = 2'b00;

    end

    reg [`WD_CODE-1:0] Code;
    initial Code = 2'b00;
    initial begin
        #475 Code = 2'b11; 
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b10;

    //2
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b00; 
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b11;

    //3
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b10;

    //4
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b00; 
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b01;

    //5
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b00; 
        #`DPERIOD Code = 2'b00; 
        #`DPERIOD Code = 2'b11;

    //6
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b10;
        #`DPERIOD Code = 2'b01;

    //7
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b00; 
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b10;

    //8
        #`DPERIOD Code = 2'b00; 
        #`DPERIOD Code = 2'b00; 
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b00; 
        #`DPERIOD Code = 2'b01;

    //9
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b00; 
        #`DPERIOD Code = 2'b10;

    //10
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b00; 
        #`DPERIOD Code = 2'b01;

    //11
        #`DPERIOD Code = 2'b01;
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b01; 
        #`DPERIOD Code = 2'b00;

    //12
        #`DPERIOD Code = 2'b10; 
        #`DPERIOD Code = 2'b11; 
        #`DPERIOD Code = 2'b00;
    
    end

    reg Active;
    always @(Code or Reset) 
        if (~Reset) Active <= 0;
        else if (Code!=0) Active <= 1;

    reg D_CLOCK;
    initial D_CLOCK = 0;
    always #(`DPERIOD/2) D_CLOCK <= ~D_CLOCK;

    wire DecodeOut;
    VITERBIDECODER vd (Reset, CLOCK, Active, Code, DecodeOut); 
    
endmodule