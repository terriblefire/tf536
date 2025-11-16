`timescale 1ns / 1ps

module test_chipram_access_read;

`include "../clocks.vinc"

`include "bus_fixture.vinc"   
`include "../unittest.vinc"
`include "../common.vinc"

assign CLK = CLK7M;


always @(negedge CLK7M or posedge AS) begin 

    if (AS == 1'b1) begin 
        
        DTACK <= 1'b1;

    end else begin 

        DTACK <= UDS & LDS;

    end

end

initial begin 

    $dumpfile("test_chipram_access_read.vcd");
    $dumpvars(0, test_chipram_access_read);

    RESET = 0;
    #100;

    RESET = 1;

    #100;

    // arrange 

    D_AMIGA_OUT = 16'hAAAA;

    // act
    readw(32'h00001000);

    #10;

    // assert
    // check_cycle was terminated by DTACK
    assertexactly(_termination[1:0], 2'b01);
    
    assertexactly({_data_bus_sample[31:16]}, 16'hAAAA);

    #10;

    $finish;

end 

endmodule