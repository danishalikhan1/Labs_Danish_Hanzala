module DataMemory(
    input clk,
    input MemWrite,
    input MemRead,
    input [8:0] address,
    input [31:0] writeData,
    output reg [31:0] readData
);

    reg [31:0] memory [0:511];

    // Write (synchronous)
    always @(posedge clk) begin
        if (MemWrite)
            memory[address] <= writeData;
    end

    // Read (combinational)
    always @(*) begin
        if (MemRead)
            readData = memory[address];
        else
            readData = 32'b0;
    end

endmodule