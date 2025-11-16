`timescale 1ns / 1ps

module test_fastram_access_read;

`include "../clocks.vinc"

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

    $dumpfile("test_fastram_access_read.vcd");
    $dumpvars(0, test_fastram_access_read);

    RESET = 0;
    #100;

    RESET = 1;

    #100;

    readw(32'h40001000);

    #10;

    // check_cycle was terminated by STERM
    assert(_termination[TERM_STERM], 1'b0);

    #10;

    $finish;

end 

endmodule