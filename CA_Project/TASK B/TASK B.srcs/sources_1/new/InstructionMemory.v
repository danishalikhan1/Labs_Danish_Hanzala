module InstructionMemory(
    input [31:0] addr,
    output [31:0] instr
);
(* rom_style = "distributed" *) reg [31:0] memory [0:255];


assign instr = memory[addr[9:2]]; // word-aligned

initial begin
    // PC = 0: lui x5, 0            (x5 becomes 0) -> U-TYPE TEST
    memory[0] = 32'h000002B7; 

    // PC = 4: ori x5, x5, 18       (x5 becomes 18) -> I-TYPE TEST
    memory[1] = 32'h0122E293; 

    // PC = 8: addi x6, x0, 18      (x6 becomes 18) 
    memory[2] = 32'h01200313; 

    // PC = 12: bne x5, x6, 8       (18 == 18, so DO NOT branch. Continue to PC=16) -> B-TYPE TEST
    memory[3] = 32'h00629463; 

    // PC = 16: jal x1, 8           (Jump directly to PC=24, saves PC=20 in x1) -> J-TYPE TEST
    memory[4] = 32'h008000EF; 

    // PC = 20: addi x5, x0, 99     (This gets skipped! If x5 is 99, your jump failed)
    memory[5] = 32'h06300293; 

    // PC = 24: sw x5, 12(x0)       (Writes '18' to Data Mem address 0xC. This triggers the Seven Segment display!)
    memory[6] = 32'h00502623; 

    // PC = 28: jal x0, 0           (Infinite Loop at the end to hold state)
    memory[7] = 32'h0000006F; 
end

endmodule