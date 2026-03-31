module Switch_Interface(
    input readEnable,
    input [15:0] switches,
    output [31:0] readData
);

assign readData = (readEnable) ? {16'b0, switches} : 32'b0;

endmodule