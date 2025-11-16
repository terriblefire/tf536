

module intreqr(

           input CLK,

           input [31:0] A,
           inout [15:0] D,

           input AS20,
           input RW20,
           input INT2,

           input DTACK,

           output  ACK,
           output  reg BUSEN,
           output  WAIT
       );

// chipset read of DFF01e
wire ACCESS = (A[31:0] != 32'h00DFF01E) | AS20 | ~RW20;

localparam DELAYS = 2;

reg DTACK_D = 1'b1;
reg DTACK_D2 = 1'b1;

reg [15:0] data;
reg [DELAYS:0] count;

always @(negedge DTACK, posedge AS20) begin

    if (AS20 == 1'b1) begin

        DTACK_D <= 1'b1;

    end else begin

        DTACK_D <= ACCESS;

    end

end

always @(negedge CLK, posedge AS20) begin

    if (AS20 == 1'b1) begin

        BUSEN <= 1'b0;

    end else begin

        BUSEN <= ~count[DELAYS-1];

    end
end

always @(posedge CLK, posedge AS20) begin

    if (AS20 == 1'b1) begin

        DTACK_D2 <= 1'b1;
        count <= 3'b111;

    end else begin

        // do not allow dtack to reach CPU.
        if (DTACK_D == 1'b0) begin

            DTACK_D2 <= DTACK_D;
            // counts a bunch of delays
            count <= {count[DELAYS-1:0], ACCESS};

            if (BUSEN == 1'b0) begin

                data <= {D[15:4], D[3] | ~INT2, D[2:0]};

            end

        end

    end

end

assign WAIT  = ~ACCESS;
assign ACK   = count[DELAYS];
assign D     = count[DELAYS] ? 16'bzzzzzzzz_zzzzzzzz : data;

endmodule
