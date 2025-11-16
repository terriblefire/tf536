// $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/xec_libs/data/unisims/FDCPE.v,v 1.1 2005/05/10 01:20:03 wloo Exp $

/*

FUNCTION        : D-FLIP-FLOP with async clear, async preset and clock enable

*/

// `celldefine
`timescale  100 ps / 10 ps

module FDCPE (Q, C, CE, CLR, D, PRE);

    parameter INIT = 1'b0;

    output Q;
    reg    Q;

    input  C, CE, CLR, D, PRE;

        always @(posedge CLR or posedge PRE or posedge C)
            if (CLR)
                Q <= 0;
            else if (PRE)
                Q <= 1;
            else if (CE)
                Q <= D;

endmodule
