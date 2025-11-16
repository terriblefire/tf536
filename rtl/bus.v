`timescale 1ns / 1ps

/*
TF536 - 68030 Accelerator for Amiga 500/CDTV

Copyright (c) 2016-2025 Stephen J. Leary

This work is licensed under the Creative Commons Attribution-NoDerivatives
4.0 International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by-nd/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

module bus(

           input 	CLKCPU,
           input 	CLK7M,

           input 	BG30,
           input 	AS30,
           input 	DS30,
           input 	RW30,

           output 	RW,


           input [2:0] 	FC,
           input [1:0] 	SIZ,

           input [23:0] A,

           input 	BGACK,
           input 	DTACK,

           output 	BG,
           output 	LDS,
           output 	UDS,

           output 	AS,
           output 	BERR,

           input 	PUNT,

           output   DSACK1

       );


/* Timing Diagram
                 S0 S1 S2 S3 S4 S5  W  W S6 S7
         __    __    __    __    __    __    __    __    __    __    __    __   
CLK     |  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
        ________________                       _____________________________
AS30                    \_____________________/
        ___________________                      _____________________________
AS30DLY                    \_____________________/
        ____________________                     _____________________________
PUNT                    \___________________/

*/

reg AS30DLY = 1'b1;

reg BG_INT;
reg BGACK_INT;

reg RW_INT = 1'b1;
reg AS_INT = 1'b1;
reg AS_INTD = 1'b1;

reg LDS_INT = 1'b1;
reg UDS_INT = 1'b1;

wire CPUSPACE = &FC;
wire FPUOP = CPUSPACE & ({A[19:16]} === {4'b0010});

wire BUS_BUSY = BGACK & BGACK_INT;
wire HIGHZ = ~BUS_BUSY | ~PUNT;

wire DSACK1_SYNC;

reg DTACK_LATCHED;
reg DTACK_S6;
reg DTACK_S7;
wire DTACK_S7D;
reg [1:0] DSACK_INT;

bus_delay DELAY(
              .AS     ( AS        ),
              .DTACK  ( DTACK_S7  ),
              .OUT    ( DTACK_S7D )
          );

reg CANSTART = 1'b1;

// This block ensures that we see at least
// 1 falling edge of the slow clock before
// starting a new slow bus cycle.
always @(negedge CLK7M or negedge AS) begin

    if (AS == 1'b0) begin

        CANSTART <= 1'b0;

    end else begin

        CANSTART <= BUS_BUSY;

    end

end

always @(posedge CLKCPU) begin

    BGACK_INT <= BGACK;

end

wire AS_AMIGA = AS30DLY | FPUOP | ~PUNT | ~BUS_BUSY | (~CANSTART & AS_INT);

always @(posedge CLK7M or posedge AS30) begin

    if (AS30 == 1'b1) begin

        AS_INT <= 1'b1;
        AS_INTD <= 1'b1;

        RW_INT <= 1'b1;

        LDS_INT <= 1'b1;
        UDS_INT <= 1'b1;

        DTACK_S6 <= 1'b1;

    end else begin

        // assert these lines in S2
        // the 68030 assert them one half clock early.
        AS_INT <= AS_AMIGA;  // Low in S2+
        AS_INTD <= AS_INT;   // Low in S4+

        RW_INT <= RW30 | AS_AMIGA;

        if (RW30 == 1'b1) begin

            // reading when reading the signals are asserted in 7Mhz S2
            UDS_INT <= DS30 | A[0] | AS_AMIGA;
            LDS_INT <= DS30 | ({A[0], SIZ[1:0]} == 3'b001) | AS_AMIGA;

        end else begin

            // when writing the the signals are asserted in 7Mhz S4
            UDS_INT <= DS30 | AS_INT | A[0] | AS_AMIGA;
            LDS_INT <= DS30 | AS_INT  | ({A[0], SIZ[1:0]} == 3'b001) | AS_AMIGA;

        end

        DTACK_S6 <= DTACK_LATCHED;

    end

end

always @(posedge CLKCPU or posedge BG30) begin

    if (BG30 == 1'b1) begin

        BG_INT <= 1'b1;

    end else begin

        if (AS30 == AS_INT) begin

            BG_INT <= BG30;

        end

    end

end


always @(negedge CLK7M or posedge AS30) begin

    if (AS30 == 1'b1) begin

        DTACK_LATCHED <= 1'b1;
        DTACK_S7 <= 1'b1;

    end else begin

        // latch DTACK on the falling edge of S5
        // Wait states will get introducted if DTACK isnt ready
        DTACK_LATCHED <= AS_INTD | DTACK; // enter S5
        DTACK_S7 <= DTACK_S6;

    end

end

always @(posedge CLKCPU or posedge AS30) begin

    if (AS30 == 1'b1) begin

        DSACK_INT <= 2'b11;

    end else begin

        DSACK_INT <= {DSACK_INT[0], DTACK_S7D};

    end

end


always @(posedge CLKCPU or posedge AS30) begin

    if (AS30 == 1'b1) begin

        AS30DLY <= 1'b1;

    end else begin

        // Delayed Address Strobes
        AS30DLY <= AS30 | FPUOP;

    end

end

assign RW =  RW_INT;
assign AS =   AS_INT;
assign UDS =  UDS_INT;
assign LDS =  LDS_INT;

assign DSACK1 = FPUOP | DSACK_INT[0];

assign BG = BG_INT ? 1'bz : 1'b0;

endmodule
