`timescale 1ns / 1ps

/*
TF536 - 68030 Accelerator for Amiga 500/CDTV

Copyright (c) 2016-2025 Stephen J. Leary

This work is licensed under the Creative Commons Attribution-NoDerivatives
4.0 International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by-nd/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

module main_top #(
           parameter CLOCK_PHASE=7
       )
       (

           input			RESET,

           // all clock lines.
           input   			CLK7M_RAW,
           input   			CLK100M,
           output   		CLKCPU,
           output  			CLKRAM,

           input [31:0]    	A,
           inout [15:0]   	D,

           //  SDRAM Control
           output			CLKRAME,
           output [12:0]    ARAM,
           output [1:0] 	BA,
           output			CAS,
           output [3:0] 	DQM,
           output			RAMWE,
           output			RAS,
           output			RAMCS,
           output			RAMOE,

           // transfer control lines
           input [1:0] 		SIZ,
           input [2:0] 		FC,
           output[2:0] 		IPL,

           // cache control lines.
           input			CBREQ,
           output			CBACK,
           output			CIIN,

           // 68030 control lines
           input			AS30,
           input			DS30,
           input			RW30,

           output [1:0] 	DSACK,
           output			STERM,
           output           AVEC,

           output			BGACK30,
           output			BR30,
           input			BG30,

           // A500 68000 control lines
           output			AS,
           output           LDS,
           output           UDS,

           input			BR,
           output			BG,
           input			BGACK,

           input    		DTACK,

           input            VPA,
           output           E,
           output           VMA,

           output			BERR,
           output           BUSEN,

           // IDE lines

           output			IOW,
           output           IOR,

           input			IDEINT,
           input			IDEWAIT,
           output [1:0] 	IDECS

       );

reg HIGHZ;
reg BGACK_INT = 1'b1;
reg PUNT_INT = 1'b1;

reg CPCS_INT;
reg AVEC_INT;

wire CPUSPACE = &FC;
wire FPUOP = CPUSPACE & ({A[19:16]} === {4'b0010});
wire IACK = CPUSPACE & ({A[19:16]} === {4'b1111});

wire GAYLE_IDE;
wire DTACK_IDE;

reg SPEED_D;

wire CLK7M;

clocks # (
           .CLOCK_PHASE(CLOCK_PHASE)
       )
       CLOCKS(

           .CLK100M ( CLK100M ),
           .CLK7M_RAW  ( CLK7M_RAW   ),
           .CLK7M   ( CLK7M), // clean 7M clock
           .SPEED   ( SPEED_D ),
           .CLKCPU  ( CLKCPU  )
       );

wire DSACK1_SYNC;
wire VMA_INT;

// module to control the 6800 bus timings
m6800 M6800BUS(
          .CLK7M	( CLK7M         ),
          .FC       ( FC            ),
          .AS20	    ( AS30			),
          .VPA		( VPA			),
          .VMA		( VMA_INT   	),
          .E		( E				),
          .DSACK1	( DSACK1_SYNC 	)
      );

// module to control IDE timings.
ata ATA (

        .CLK	( CLKCPU	),
        .AS	    ( AS30      ),
        .RW	    ( RW30	    ),
        .A		( A		    ),
        // IDEWait not connected on TF328.
        .WAIT	( 1'b1	    ),

        .IDECS  ( IDECS	    ),
        .IOR	( IOR		),
        .IOW	( IOW		),
        .DTACK  ( DTACK_IDE	),
        .ACCESS ( GAYLE_IDE )

    );


// produce an internal data strobe
wire GAYLE_INT2;
wire GAYLE_ACCESS;

wire gayle_dout;

reg   GAYLE_DS;

                 gayle GAYLE(

                           .CLKCPU ( CLKCPU        ),
                           .RESET  ( RESET         ),

                           .AS20   ( AS30          ),
          .DS20   ( GAYLE_DS      ),
                           .RW     ( RW30          ),

                           .A      ( A             ),

                           .IDE_INT( IDEINT        ),
          .INT2   ( GAYLE_INT2    ),
                           .DIN    ( D[15]         ),

                           .DOUT   ( gayle_dout    ),
          .ACCESS ( GAYLE_ACCESS  )

                       );

             wire ram_decode ;
wire zii_decode;
wire [7:4] zii_dout;

                 autoconfig AUTOCONFIG(

                                .RESET  ( RESET         ),

                                .AS20   ( AS30          ),
                                .DS20   ( DS30          ),
                                .RW20   ( RW30          ),

                                .A      ( A             ),

                                .DOUT   ( zii_dout[7:4] ),

                                .ACCESS ( zii_decode	),
                                .DECODE ( ram_decode    )
                            );

             reg ram_access;
wire WAIT;

sdram SDRAM (

          .RESET(RESET),

          .CLKCPU (CLKCPU),
          .CLK    (CLKRAM),
          .CLKRAME(CLKRAME),

          .ACCESS(ram_access),

          .A(A),
          .SIZ(SIZ),

          .AS30(AS30),
          .RW30(RW30),
          .DS30(DS30),

          .CBACK(CBACK),
          .CIIN(CIIN),
          .CBREQ(CBREQ),

          .STERM(STERM),

          .ARAM(ARAM),
          .BA(BA),

          .CAS(CAS),
          .RAS(RAS),

          .DQM(DQM),

          .RAMWE(RAMWE),

          .WAIT   ( WAIT      ),
          .RAMCS(RAMCS),
          .RAMOE(RAMOE)
      );


reg rom_access;

`ifndef CDTV
wire rom_decode = ({A[31:14]} != {16'h00F0, 2'b00});
`else
wire rom_decode = 1'b1;
`endif

wire [15:0] rom_dout;

bootrom ROM(

    .clk (CLKCPU),
    .address ({A[7:1]}),
    .data   (rom_dout)
);


wire DSACK_INTREQR;
wire WAIT_INTREQR;
wire BUSEN_INTREQR;

                 // patch up intenar when its read by the Amiga 500
                 intreqr INT2EMU(

                             .CLK  ( CLKCPU ),
                             .AS20 ( AS30   ),
                             .RW20 ( RW30   ),
                             .DTACK ( DTACK ),

            .INT2     ( GAYLE_INT2    ),

            .ACK      ( DSACK_INTREQR    ),
            .WAIT     ( WAIT_INTREQR     ),
            .BUSEN    ( BUSEN_INTREQR    ),

                             .A ( A ),
                             .D ( D )
                         );

                 // interrupt assert/acknowledge path.
                 interrupt # (.INT_LEVEL(3'b010)) INTLEVEL2 (

                               .CLK    ( CLK100M   ),
                               .RESET  ( RESET     ),
                               .A      ( A         ),
                               .AS     ( AS        ),
                               .FC     ( FC        ),
                               .IPL    ( IPL       ),
             .INT    ( GAYLE_INT2)
                           );


             reg intcycle_dout = 1'b0;
reg fastcycle_int;
reg FASTCYCLE;

always @(negedge CLKCPU or posedge AS30) begin

    if (AS30 == 1'b1) begin

        intcycle_dout <= 1'b0;
        fastcycle_int <= 1'b1;
        FASTCYCLE <= 1'b1;
        CPCS_INT <= 1'b1;
        AVEC_INT <= 1'b1;

    end else begin

        intcycle_dout <= ~(GAYLE_ACCESS & zii_decode & rom_decode) & RW30;
        fastcycle_int <= GAYLE_ACCESS & zii_decode & rom_decode;
        FASTCYCLE <= fastcycle_int;
        CPCS_INT <= ~FPUOP | AS30;
        AVEC_INT <= ~IACK | VPA;

    end
end

reg [1:0] AS_RESYNC = 2'b00;

reg BUSEN_D;
reg DTACK_D;

reg AS_D;
reg LDS_D;
reg UDS_D;

wire PUNT_COMB = GAYLE_ACCESS & ram_decode & rom_decode & GAYLE_IDE & zii_decode;

always @(posedge CLK7M or negedge SPEED_D) begin

    if (SPEED_D == 1'b0) begin

        AS_RESYNC <= 2'b11;

    end else begin

        // when writing the the signals are asserted in 7Mhz S4
        AS_RESYNC <= {AS_RESYNC[0], 1'b0};

    end

end


always @(posedge CLK7M) begin

    BGACK_INT <=  BGACK;

end


always @(posedge CLK100M) begin

    ram_access <= ram_decode | AS30;
    rom_access <= rom_decode | AS30;
    GAYLE_DS <= DS30 | GAYLE_ACCESS | AS30;
    //BGACK_INT <= (BG30 | ~AS30) & (BGACK_INT | BR) | BR;
    HIGHZ <= PUNT_INT & BGACK30;

    PUNT_INT <= PUNT_COMB;
    SPEED_D <= ~AS30 & ram_decode & GAYLE_IDE & GAYLE_ACCESS | CPUSPACE | ~BGACK_INT | ~RESET;
    
    if (AS30 == 1'b1) begin 
        DTACK_D <= 1'b1;
    end else begin 
        DTACK_D <= DTACK_D & (DTACK | DS30 | ~PUNT_INT | (|AS_RESYNC));
    end 

    BUSEN_D <= AS_D | BUSEN_INTREQR;

    // resync if necessary
    AS_D <= AS30 | ~PUNT_INT | FPUOP | AS_RESYNC[0];
    UDS_D <= DS30 | A[0] | AS_RESYNC[0] | ~RW30 & AS_RESYNC[1];
    LDS_D <= DS30 | ({A[0], SIZ[1:0]} == 3'b001)  | AS_RESYNC[0] | ~RW30 & AS_RESYNC[1];

end

wire [15:0] data_out;

assign data_out = zii_decode ? {16{1'bz}} : {zii_dout, zii_dout, 8'd0};
assign data_out = GAYLE_ACCESS ? {16{1'bz}}  : {gayle_dout,7'd0, 8'd0};
assign data_out = rom_access ? {16{1'bz}} :  rom_dout;
assign D[15:0] = intcycle_dout ? data_out : {16{1'bz}};

assign DSACK = {FASTCYCLE & DTACK_D & DSACK1_SYNC & DTACK_IDE & DSACK_INTREQR, 1'b1} | {WAIT_INTREQR & DSACK_INTREQR, 1'b1 };

assign AS = HIGHZ ? AS_D : 1'bz;
assign LDS = HIGHZ ? LDS_D : 1'bz;
assign UDS = HIGHZ ? UDS_D : 1'bz;
assign VMA = HIGHZ ? VMA_INT : 1'bz;

assign AVEC = AVEC_INT;

// bus error needs to be thrown on an FPU accses.
assign BERR = CPCS_INT ? 1'bz : 1'b0;

assign CLKRAM = CLK100M;
assign BUSEN = BUSEN_D;

assign D[15:0] = {16{1'bz}};
assign IPL[2:0] = 3'bzzz;

assign BG = BG30 | AS_RESYNC[0];
assign BR30 = BR;
assign BGACK30 = BGACK;

endmodule
