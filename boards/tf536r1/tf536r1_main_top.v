`timescale 1ns / 1ps

/*
Copyright (c) 2018, Stephen J. Leary
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:
   This product includes software developed by the <organization>.
4. Neither the name of the <organization> nor the
   names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

module tf536r1_main_top #(
           parameter CLOCK_PHASE=7
       )
       (

           inout			RESET,

           // all clock lines.
           inout   			CLK7M_RAW,
           inout   			CLK100M,
           inout   		    CLKCPU,
           inout  			CLKRAM,

           inout [31:0]    	A,
           inout [15:0]   	D,

           //  SDRAM Control
           inout			CLKRAME,
           inout [12:0]    ARAM,
           inout [1:0] 	BA,
           inout			CAS,
           inout [3:0] 	DQM,
           inout			RAMWE,
           inout			RAS,
           inout			RAMCS,
           inout			RAMOE,

           // transfer control lines
           inout [1:0] 		SIZ,
           inout [2:0] 		FC,
           inout [2:0] 		IPL,

           // cache control lines.
           inout			CBREQ,
           inout			CBACK,
           inout			CIIN,

           // 68030 control lines
           inout			AS30,
           inout			DS30,
           inout			RW30,

           inout [1:0] 	    DSACK,
           inout			STERM,
           inout            AVEC,

           inout			BGACK30,
           inout			BR30,
           inout			BG30,

           // A500 68000 control lines
           inout			AS,
           inout			DS,
           inout           LDS,
           inout           UDS,

           inout			BR,
           inout			BG,
           inout			BGACK,

           input    		DTACK,

           inout            VPA,
           inout            E,
           inout            VMA,

           inout			BERR,

           inout            BUSEN,

           // IDE lines

           inout			IOW,
           inout           IOR,

           inout			IDEINT,
           inout			IDEWAIT,
           inout [1:0] 	IDECS
       );



// Instantiate the Unit Under Test (UUT)
main_top #(.CLOCK_PHASE(CLOCK_PHASE))
         MAIN_TOP (
             .RESET(RESET),
             .CLK7M_RAW(CLK7M_RAW),
             .CLK100M(CLK100M),
             .CLKCPU(CLKCPU),
             .CLKRAM(CLKRAM),
             .A(A),
             .D(D),
             .CLKRAME(CLKRAME),
             .ARAM(ARAM),
             .BA(BA),
             .CAS(CAS),
             .DQM(DQM),
             .RAMWE(RAMWE),
             .RAS(RAS),
             .RAMCS(RAMCS),
             .RAMOE(RAMOE),
             .SIZ(SIZ),
             .FC(FC),
             .IPL(IPL),
             .CBREQ(CBREQ),
             .CBACK(CBACK),
             .CIIN(CIIN),
             .AS30(AS30),
             .DS30(DS30),
             .RW30(RW30),
             .DSACK(DSACK),
             .STERM(STERM),
             .AVEC(AVEC),
             .BGACK30(BGACK30),
             .BR30(BR30),
             .BG30(BG30),
             .AS(AS),
             .LDS(LDS),
             .UDS(UDS),
             .BR(BR),
             .BG(BG),
             .BGACK(BGACK),
             .DTACK(DTACK),
             .VPA(VPA),
             .E(E),
             .VMA(VMA),
             .BERR(BERR),
             .BUSEN(BUSEN),
             .IOW(IOW),
             .IOR(IOR),
             .IDEINT(IDEINT),
             .IDEWAIT(IDEWAIT),
             .IDECS(IDECS)
         );


endmodule
