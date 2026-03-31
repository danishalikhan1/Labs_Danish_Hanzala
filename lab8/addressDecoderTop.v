module addressDecoderTop(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] address,
    input  wire        readEnable,
    input  wire        writeEnable,
    input  wire [31:0] writeData,
    input  wire [15:0] switches,

    output wire [31:0] readData,
    output wire [15:0] leds
);

    // --------------------------------------------------
    // Internal control signals from decoder
    // --------------------------------------------------
    wire DataMemRead;
    wire DataMemWrite;
    wire LEDWrite;
    wire SwitchReadEnable;

    // --------------------------------------------------
    // Internal data wires
    // --------------------------------------------------
    wire [31:0] DataMemReadData;
    wire [31:0] SwitchReadData;

    // ==================================================
    // Address Decoder
    // ==================================================
    AddressDecoder decoder (
        .deviceSelect(address[9:8]),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .DataMemRead(DataMemRead),
        .DataMemWrite(DataMemWrite),
        .LEDWrite(LEDWrite),
        .SwitchReadEnable(SwitchReadEnable)
    );

    // ==================================================
    // Data Memory (512 x 32)
    // ==================================================
    DataMemory dataMem (
        .clk(clk),
        .MemWrite(DataMemWrite),
        .MemRead(DataMemRead),
        .address(address[8:0]),   // local address
        .writeData(writeData),
        .readData(DataMemReadData)
    );

    // ==================================================
    // LED Interface (Write Only)
    // ==================================================
    LED_Interface ledModule (
        .clk(clk),
        .rst(rst),
        .writeEnable(LEDWrite),
        .writeData(writeData[15:0]),
        .leds(leds)
    );

    // ==================================================
    // Switch Interface (Read Only)
    // ==================================================
    Switch_Interface switchModule (
        .readEnable(SwitchReadEnable),
        .switches(switches),
        .readData(SwitchReadData)
    );

    // ==================================================
    // READ DATA MUX
    // ==================================================
    assign readData =
        (address[9:8] == 2'b00) ? DataMemReadData :
        (address[9:8] == 2'b10) ? SwitchReadData :
        32'b0;

endmodule