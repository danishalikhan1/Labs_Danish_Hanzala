module Basys3_Top(
    input clk,              // 100MHz
    input btnC,             // Reset
    input [15:0] sw,        // Switches
    output [6:0] seg,
    output [3:0] an,
    output [15:0] led
);
    // 1Hz Clock Divider
    reg [26:0] count = 0;
    reg clk_1s = 0;
    always @(posedge clk) begin
        if (count == 49_999_999) begin
            count <= 0;
            clk_1s <= ~clk_1s;
        end else count <= count + 1;
    end

    wire [31:0] alu_val;

    TopLevelProcessor CPU (
        .clk(clk_1s),
        .clk_fast(clk),
        .reset(btnC),
//        .sw(sw),
        .debug_out(alu_val),
        .seg(seg),
        .an(an)
    );
    assign led[15] = clk_1s;
    assign led[14:0] = alu_val[15:0];
endmodule