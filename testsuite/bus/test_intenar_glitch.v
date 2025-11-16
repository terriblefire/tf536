`timescale 1ns / 1ps

module test_intenar_glitch;

`include "../clocks.vinc"

reg IDEINT = 1'b1;

`include "bus_fixture.vinc"   
`include "../unittest.vinc"
`include "../common.vinc"

assign CLK = CLKCPU;

always @(negedge CLKCPU or posedge AS) begin 

    if (AS == 1'b1) begin 
        
        DTACK <= 1'b1;

    end else begin 

        DTACK <= UDS & LDS;

    end

end

initial begin 

    $dumpfile("test_intenar_glitch.vcd");
    $dumpvars(0, test_intenar_glitch);

    RESET = 0;
    #100;

    RESET = 1;

    #100;

    writeb(32'h00DAA000, 8'h80);

    #100;

    // arrange

    D_AMIGA_OUT = 16'h0402;

    // act 
    IDEINT = 1'b0;
    @(posedge CLKCPU);
    A <= 32'h00DFF01E;
    AS30 <= 1'b1;
    DS30 <= 1'b1;
    @(negedge CLKCPU);
    AS30 <= 1'b0;
    @(negedge CLKCPU);
    DS30 <= 1'b0;
    wait(~DTACK);

    #5;
    IDEINT = 1'b1;
    wait(~DSACK[1]);

    #100;

    $finish;

end 

endmodule