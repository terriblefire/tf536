`timescale 1ns / 1ps

module test_intenar_patch;

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

    $dumpfile("test_intenar_patch.vcd");
    $dumpvars(0, test_intenar_patch);

    RESET = 0;
    #100;

    RESET = 1;

    #100;

    writeb(32'h00DAA000, 8'h80);

    #100;

    // arrange
    IDEINT = 1'b0;
    D_AMIGA_OUT = 16'h0402;

    // act 
    readw(32'h00DFF01E);

    // assert
    assert(D[31:16], 16'h0402);

    #100;

    
    // arrange
    IDEINT = 1'b1;
    D_AMIGA_OUT = 16'h0402;

     // act 
    readw(32'h00DFF01E);


    // assert
    assert(D[31:16], 16'h040A);

    #100;

    $finish;

end 

endmodule