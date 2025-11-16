`timescale 1ns / 1ps

/*
TF536 - 68030 Accelerator for Amiga 500/CDTV

Copyright (c) 2016-2025 Stephen J. Leary

This work is licensed under the Creative Commons Attribution-NoDerivatives
4.0 International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by-nd/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

module bus_delay(
    
        input AS,
        input DTACK,
        output OUT
        );
   
parameter DELAYS = 10;
 
   wire [DELAYS:0] dtack_int;
   
 
genvar    c;
generate
   
   for (c = 0; c < DELAYS; c = c + 1) begin: dtackint
 
      FDCP #(.INIT(1'b1))
      DTTACK_FF (
         .Q(dtack_int[c+1]), // Data output
         .C(~dtack_int[c]), // Clock input
         .CLR(1'b0), // Asynchronous clear input
         .D(1'b0), // Data input
         .PRE(AS) // Asynchronous set input
         );
   end
   
endgenerate

assign dtack_int[0] = DTACK;
assign OUT = dtack_int[DELAYS];
   
endmodule