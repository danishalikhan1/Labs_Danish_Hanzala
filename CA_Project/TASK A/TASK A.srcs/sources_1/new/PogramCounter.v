module ProgramCounter(
    input clk,
    input reset,
    input [31:0] nextPC,
    output reg [31:0] PC
);

always @(posedge clk or posedge reset) begin
    if (reset)
        PC <= 32'b0;
    else
        PC <= nextPC;
end

endmodule