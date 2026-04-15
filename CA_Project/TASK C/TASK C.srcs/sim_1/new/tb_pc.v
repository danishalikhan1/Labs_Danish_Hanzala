`timescale 1ns/1ps

module tb_pc;

reg clk, reset, PCSrc;
reg [31:0] instr;

wire [31:0] PC, nextPC, PC_plus4, branchAddr, imm;

// Instantiate modules
ProgramCounter pc(clk, reset, nextPC, PC);
pcAdder add4(PC, PC_plus4);
immGen ig(instr, imm);
branchAdder badd(PC, imm, branchAddr);
mux2 mux(PC_plus4, branchAddr, PCSrc, nextPC);

// Clock generation
always #5 clk = ~clk;

initial begin
    clk = 1;
    reset = 1;
    PCSrc = 0;

    #10 reset = 0;

    // Case 1: Sequential execution (PC + 4)
    #20;

    // Case 2: Branch instruction
    // Example B-type instruction (fake for testing)
    instr = 32'b00000000000100000000000001100011;

    PCSrc = 1; // take branch
    #20;

    // Back to sequential
    PCSrc = 0;
    #20;

    $stop;
end

endmodule