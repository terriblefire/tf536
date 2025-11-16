`timescale 1ns / 1ps

module test_interrupt_level2_asserted;

localparam INT_LEVEL = 3'd2;

`include "interrupt_fixture.vinc"   
`include "../unittest.vinc"
`include "../clocks.vinc"
`include "../common.vinc"

assign CLK = CLK7M;

initial begin 

    $dumpfile("test_interrupt_level2_asserted.vcd");
    $dumpvars(0, test_interrupt_level2_asserted);

    RESET = 0;
    #100;

    RESET = 1;
    FC = 0;
    A = 0;

    #100;

    assert(3'b111, IPL);

    #100;

    INT = 0;

    #100;

    assert(3'b101, IPL);
    

    $finish;

end 

endmodule