`timescale 1ns / 1ps

/*
TF536 - 68030 Accelerator for Amiga 500/CDTV

Copyright (c) 2016-2025 Stephen J. Leary

This work is licensed under the Creative Commons Attribution-NoDerivatives
4.0 International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by-nd/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

module interrupt(
           input        CLK,
           input        RESET,
           input        AS,
           input [31:0] A,
           input [2:0]  FC,
           output [2:0] IPL,
           input        INT

       );

parameter INT_LEVEL = 3'b010;

wire CPUSPACE = &FC;
wire IACK = CPUSPACE & ({A[19:16]} === {4'b1111});

wire INT_IACK = IACK & ({A[3:1]} == INT_LEVEL) & ~AS;

reg INT_ASSERT = 1'b0;

reg INT_IACK_D;

always @(negedge INT, posedge INT_IACK_D) begin

    if (INT_IACK_D == 1'b1) begin

        INT_ASSERT <= 1'b0;

    end else begin

        INT_ASSERT <= 1'b1;

    end

end

always @(posedge CLK or negedge RESET) begin

    if (RESET == 1'b0) begin
        INT_IACK_D <= 1'b0;
    end else begin
        INT_IACK_D <= INT_IACK;
    end

end

assign IPL[2:0] = INT_ASSERT ? {~INT_LEVEL} : {3'bzzz};

endmodule
