module branchAdder(
    input [31:0] PC,
    input [31:0] imm,
    output [31:0] branchAddr
);
    // Add the immediate (number of words) directly to the PC
    assign branchAddr = PC + imm; 
endmodule