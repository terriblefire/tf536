`timescale 1ns / 1ps

/*
TF536 - 68030 Accelerator for Amiga 500/CDTV

Copyright (c) 2016-2025 Stephen J. Leary

This work is licensed under the Creative Commons Attribution-NoDerivatives
4.0 International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by-nd/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

module ata (
           input         CLK,
           input         AS,
           input         RW,
           input [31:0] A,
           input        WAIT,

           output [1:0] IDECS,
           output        IOR,
           output        IOW,
           output        DTACK,
           output        ACCESS

       );

/* Timing Diagram
                 S0 S1 S2 S3 S4 S5  W  W S6 S7
     __    __    __    __    __    __    __    __    __    __    __    __   
CLK |  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
     _________________                         _____________________________
AS                    \\\_____________________/
    _______________                            _____________________________
CS                 \__________________________/
    ______________________                     _____________________________
IOR                       \___________________/
    _____________________________        ___________________________________
IOW                              \______/
    _____________________________        ___________________________________
DTACK                            \______/     
    _________________________       ________________________________________
WAIT                         \_____/
        
*/

// decode directly from AS and Address Bus.
wire GAYLE_IDE = ({A[31:15]} != {16'h00DA,1'b0});

reg ASDLY = 1'b1;
reg ASDLY2 = 1'b1;
reg DTACK_INT = 1'b1;

reg IOR_INT = 1'b1;
reg IOW_INT = 1'b1;

always @(posedge CLK or posedge AS) begin

    if (AS == 1'b1) begin

        ASDLY <= 1'b1;
        ASDLY2 <= 1'b1;

    end else begin

        ASDLY <= AS;
        ASDLY2 <= ASDLY;

    end

end

always @(posedge CLK or posedge AS) begin

    if (AS == 1'b1) begin

        IOR_INT <= 1'b1;
        IOW_INT <= 1'b1;
        DTACK_INT <= 1'b1;

    end else begin

        IOR_INT <= ~RW | ASDLY | GAYLE_IDE;
        IOW_INT <=  RW | ASDLY2 | GAYLE_IDE;
        DTACK_INT <=  ASDLY2 | GAYLE_IDE;

    end

end

assign IOR = IOR_INT;
assign IOW = IOW_INT ;
assign DTACK = DTACK_INT;

assign IDECS = A[12] ? {GAYLE_IDE, 1'b1} : {1'b1, GAYLE_IDE};
assign ACCESS = GAYLE_IDE;


endmodule
