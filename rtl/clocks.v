`timescale 1ns / 1ps

/*
TF536 - 68030 Accelerator for Amiga 500/CDTV

Copyright (c) 2016-2025 Stephen J. Leary

This work is licensed under the Creative Commons Attribution-NoDerivatives
4.0 International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by-nd/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

module clocks #(
           parameter CLOCK_PHASE=7
       )(
           input      CLK100M,
           input      CLK7M_RAW,
           input      SPEED,
           output     CLKCPU,
           output reg CLK50M,
           output     CLK7M

       );

localparam CLOCK_SMOOTHING = 4;
localparam CLOCK_PIPE_SIZE = (CLOCK_PHASE <=  CLOCK_SMOOTHING) ? CLOCK_SMOOTHING : CLOCK_PHASE;

reg SPEED_D = 0;
reg CLK50MI = 0;
reg [CLOCK_PIPE_SIZE:0] CLK7M_D = 'd0;

wire can_change = (&CLK7M_D[CLOCK_SMOOTHING:0] == 1'b1) || (|CLK7M_D[CLOCK_SMOOTHING:0] == 1'b0);

always @(posedge CLK100M) begin

    SPEED_D <= SPEED;
    CLK50M <= ~CLK50M;

    if (can_change == 1) begin
        CLK7M_D <= {CLK7M_D[CLOCK_PHASE-1:0], ~CLK7M_RAW};
    end else begin
        CLK7M_D <= {CLK7M_D[CLOCK_PHASE-1:0], CLK7M_D[0]};
    end

    if (SPEED_D) begin
        // use the inverse of the clock to move the 030 into the correct phase.
        CLK50MI <=  ~CLK7M_D[CLOCK_PHASE-1];
    end else begin
        CLK50MI <= ~CLK50MI;
    end

end

assign CLKCPU = CLK50MI;
assign CLK7M = CLK7M_D[CLOCK_PHASE-1];

endmodule
