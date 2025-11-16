module bootrom
(
        input		clk,	// bus clock
        input [6:0]	address,	// address in
        output reg [15:0]	data	// data out
);

always @(posedge clk) begin
	case (address)
		7'd0:	data	<=	16'h1111;
		7'd1:	data	<=	16'h49f9;
		7'd2:	data	<=	16'h00df;
		7'd3:	data	<=	16'hf000;
		7'd4:	data	<=	16'h303c;
		7'd5:	data	<=	16'h7fff;
		7'd6:	data	<=	16'h3940;
		7'd7:	data	<=	16'h009a;
		7'd8:	data	<=	16'h3940;
		7'd9:	data	<=	16'h009c;
		7'd10:	data	<=	16'h3940;
		7'd11:	data	<=	16'h0096;
		7'd12:	data	<=	16'h397c;
		7'd13:	data	<=	16'h0200;
		7'd14:	data	<=	16'h0100;
		7'd15:	data	<=	16'h426c;
		7'd16:	data	<=	16'h0110;
		7'd17:	data	<=	16'h426c;
		7'd18:	data	<=	16'h0180;
		7'd19:	data	<=	16'h4240;
		7'd20:	data	<=	16'h3940;
		7'd21:	data	<=	16'h0180;
		7'd22:	data	<=	16'h323c;
		7'd23:	data	<=	16'h0032;
		7'd24:	data	<=	16'h51c9;
		7'd25:	data	<=	16'hfffe;
		7'd26:	data	<=	16'h5240;
		7'd27:	data	<=	16'hb07c;
		7'd28:	data	<=	16'h0fff;
		7'd29:	data	<=	16'h6600;
		7'd30:	data	<=	16'hffec;
		7'd31:	data	<=	16'h4ed5;
		7'd32:	data	<=	16'h2456;
		7'd33:	data	<=	16'h4552;
		7'd34:	data	<=	16'h3a74;
		7'd35:	data	<=	16'h6635;
		7'd36:	data	<=	16'h3336;
		7'd37:	data	<=	16'h7232;
		7'd38:	data	<=	16'h5f32;
		7'd39:	data	<=	16'h3032;
		7'd40:	data	<=	16'h352d;
		7'd41:	data	<=	16'h3131;
		7'd42:	data	<=	16'h2d31;
		7'd43:	data	<=	16'h355f;
		7'd44:	data	<=	16'h3335;
		7'd45:	data	<=	16'h3162;
		7'd46:	data	<=	16'h6239;
		7'd47:	data	<=	16'h3500;
		default:	data	<=	16'd0;
	endcase
end

endmodule
