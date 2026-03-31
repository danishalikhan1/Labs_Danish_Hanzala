`timescale 1ns/1ps

module MemorySystem_tb;

    // -----------------------------------------
    // Testbench Signals
    // -----------------------------------------
    reg clk;
    reg rst;

    reg [31:0] address;
    reg readEnable;
    reg writeEnable;
    reg [31:0] writeData;
    reg [15:0] switches;

    wire [31:0] readData;
    wire [15:0] leds;

    // -----------------------------------------
    // Instantiate DUT
    // -----------------------------------------
    addressDecoderTop DUT (
        .clk(clk),
        .rst(rst),
        .address(address),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .writeData(writeData),
        .switches(switches),
        .readData(readData),
        .leds(leds)
    );

    // -----------------------------------------
    // Clock Generation (10ns period)
    // -----------------------------------------
    always #5 clk = ~clk;

    // -----------------------------------------
    // Test Sequence
    // -----------------------------------------
    initial begin

        // Initialize
        clk = 0;
        rst = 1;
        address = 0;
        readEnable = 0;
        writeEnable = 0;
        writeData = 0;
        switches = 16'hA5A5; // Decimal: 42405

        // Release reset
        #15 rst = 0;

        // ====================================================
        // 1. WRITE TO DATA MEMORY (address[9:8] = 00)
        // ====================================================
        $display("Writing to Data Memory...");
        address     = 32'd32;         
        writeData   = 32'hDEADBEEF;
        writeEnable = 1;
        #10;
        writeEnable = 0;

        // ====================================================
        // 2. READ FROM DATA MEMORY
        // ====================================================
        $display("Reading from Data Memory...");
        readEnable = 1;
        #10; // Wait for data to propagate out

        // CHECK WHILE READ ENABLE IS STILL HIGH
        if (readData == 32'hDEADBEEF)
            $display("PASS: Data Memory Read Correct");
        else
            $display("FAIL: Data Memory Read Incorrect");
            
        readEnable = 0; // Turn off after checking

        // ====================================================
        // 3. WRITE TO LEDs (address[9:8] = 01)
        // ====================================================
        $display("Writing to LEDs...");
        address     = 32'd300; // FIX: 300 in binary ensures bits [9:8] are '01'      
        writeData   = 32'h00001234; // Decimal: 4660
        writeEnable = 1;
        #10;
        writeEnable = 0;
        #1; // FIX: Tiny delay to allow the non-blocking assignment (<=) to resolve

        if (leds == 16'h1234)
            $display("PASS: LED Write Correct");
        else
            $display("FAIL: LED Write Incorrect");

        // ====================================================
        // 4. READ FROM SWITCHES (address[9:8] = 10)
        // ====================================================
        $display("Reading from Switches...");
        address    = 32'd600; // FIX: 600 in binary ensures bits [9:8] are '10'       
        readEnable = 1;
        #10;

        // CHECK WHILE READ ENABLE IS STILL HIGH
        if (readData == 32'h0000A5A5)
            $display("PASS: Switch Read Correct");
        else
            $display("FAIL: Switch Read Incorrect");
            
        readEnable = 0; // Turn off after checking

        #20;
        $display("Simulation Complete.");
        $stop;
    end

endmodule