module SevenSeg_Driver(
    input clk,
    input [31:0] data,
    output reg [6:0] seg,
    output reg [3:0] an
);
    reg [1:0] refresh = 0;
    reg [17:0] refresh_count = 0;
    always @(posedge clk) refresh_count <= refresh_count + 1;
    always @(posedge refresh_count[17]) refresh <= refresh + 1;

    reg [3:0] hex_val;
    always @(*) begin
        case(refresh)
            2'b00: begin an = 4'b1110; hex_val = data[3:0];   end
            2'b01: begin an = 4'b1101; hex_val = data[7:4];   end
            2'b10: begin an = 4'b1011; hex_val = data[11:8];  end
            2'b11: begin an = 4'b0111; hex_val = data[15:12]; end
        endcase
    end

    always @(*) begin
        case(hex_val)
            4'h0: seg = 7'b1000000; 4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100; 4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001; 4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010; 4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000; 4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000; 4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110; 4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110; 4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule