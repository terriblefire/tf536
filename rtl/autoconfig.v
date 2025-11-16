`timescale 1ns / 1ps

/*
TF536 - 68030 Accelerator for Amiga 500/CDTV

Copyright (c) 2016-2025 Stephen J. Leary

This work is licensed under the Creative Commons Attribution-NoDerivatives
4.0 International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by-nd/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

module autoconfig(

           input    RESET,
           input 	AS20,
           input 	RW20,
           input 	DS20,

           input [31:0] A,

           output [7:4] DOUT,

           output  ACCESS,
           output  DECODE

       );

parameter SERIAL_NO = 536;
parameter PRODUCT_ID = 5;

reg config_out = 'd0;
reg configured = 'd0;
reg shutup = 'd0;
reg [7:4] data_out = 'd0;

// 0xE80000
wire Z2_ACCESS = ({A[31:16]} != {16'h00E8}) | (&config_out);
wire Z2_WRITE = (Z2_ACCESS | RW20);
wire [5:0] zaddr = {A[6:1]};

localparam RAM_DISABLED = 1'b0;

always @(posedge AS20 or negedge RESET) begin

    if (RESET == 1'b0) begin

        config_out <= RAM_DISABLED;

    end else begin

        config_out <= configured | shutup;

    end

end

always @(negedge DS20 or negedge RESET) begin

    if (RESET == 1'b0) begin

        configured <= RAM_DISABLED;
        shutup <= 'd0;
        data_out[7:4] <= 4'hf;

    end else begin

        if (Z2_WRITE == 1'b0) begin

            case (zaddr)
                'h22: begin //configure logic
                    configured <= 1'b1;
                end
                'h26: begin // shutup logic
                    shutup <= 1'b1;
                end
            endcase

        end

        // autoconfig ROMs
        case (zaddr)
            'h00: data_out[7:4] <= 4'ha;
            'h01: data_out[7:4] <= 4'h2;
            'h02: data_out[7:4] <= ~PRODUCT_ID[7:4];
            'h03: data_out[7:4] <= ~PRODUCT_ID[3:0];
            'h04: data_out[7:4] <= 4'h4;
            'h08: data_out[7:4] <= 4'he;
            'h09: data_out[7:4] <= 4'hc;
            'h0a: data_out[7:4] <= 4'h2;
            'h0b: data_out[7:4] <= 4'h7;
            // serial 
            'h0c: data_out[7:4] <= ~SERIAL_NO[31:28];
            'h0d: data_out[7:4] <= ~SERIAL_NO[27:24];
            'h0e: data_out[7:4] <= ~SERIAL_NO[23:20];
            'h0f: data_out[7:4] <= ~SERIAL_NO[19:16];

            'h10: data_out[7:4] <= ~SERIAL_NO[15:12];
            'h11: data_out[7:4] <= ~SERIAL_NO[11:8];
            'h12: data_out[7:4] <= ~SERIAL_NO[7:4];
            'h13: data_out[7:4] <= ~SERIAL_NO[3:0];
            default: data_out[7:4] <= 4'hf;
        endcase

    end
end

// decode the base addresses
// these are hardcoded to the address they always get assigned to.
assign DECODE = ({A[31:26]} != {6'b0100_00});

assign ACCESS = Z2_ACCESS;
assign DOUT = data_out;

endmodule
