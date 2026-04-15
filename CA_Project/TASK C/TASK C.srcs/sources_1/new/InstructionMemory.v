module InstructionMemory(
    input [31:0] addr,
    output [31:0] instr
);

(* rom_style = "distributed" *) reg [31:0] memory [0:255];

assign instr = memory[addr[9:2]]; // word-aligned

initial begin
    // --- Setup / Main Call ---
    // PC = 0: addi sp, zero, 128          (Initialize Stack Pointer)
    memory[0] = 32'h08000113;

    // PC = 4: addi t0, zero, 2            (Load immediate 2 into t0)
    memory[1] = 32'h00200293;

    // PC = 8: addi t1, zero, 4            (Load immediate 4 into t1)
    memory[2] = 32'h00400313;

    // PC = 12: addi t2, zero, 10          (Load loop counter 10 into t2)
    memory[3] = 32'h00A00393;

    // PC = 16: jal ra, 8                  (Jump to function, skip next instruction)
    memory[4] = 32'h008000EF;

    // PC = 20: j 0                        (Infinite loop / Halt program)
    memory[5] = 32'h0000006F;

    // --- Function Start ---
    // PC = 24: addi sp, sp, -16           (Allocate 16 bytes on the stack)
    memory[6] = 32'hFF010113;

    // PC = 28: sw ra, 12(sp)              (Save Return Address to stack)
    memory[7] = 32'h00112623;

    // PC = 32: sw s0, 8(sp)               (Save s0 to stack)
    memory[8] = 32'h00812423;

    // PC = 36: add s0, zero, t0           (Initialize s0 with t0's value: 2)
    memory[9] = 32'h00500433;

    // --- Loop Start ---
    // PC = 40: sw s0, 12(zero)            (Store current s0 to memory address 12)
    memory[10] = 32'h00802623;

    // PC = 44: add s0, s0, t1             (Add t1 to s0: s0 = s0 + 4)
    memory[11] = 32'h00640433;

    // PC = 48: addi t2, t2, -1            (Decrement loop counter t2)
    memory[12] = 32'hFFF38393;

    // PC = 52: bne t2, zero, -12          (If t2 != 0, branch back to PC=40)
    memory[13] = 32'hFE039AE3;

    // --- Function end ---
    // PC = 56: lw s0, 8(sp)               (Restore s0 from stack)
    memory[14] = 32'h00812403;

    // PC = 60: lw ra, 12(sp)              (Restore Return Address from stack)
    memory[15] = 32'h00C12083;

    // PC = 64: addi sp, sp, 16            (Deallocate 16 bytes from the stack)
    memory[16] = 32'h01010113;

    // PC = 68: jalr x0, 0(ra)                       (Return to caller at PC=20)
    memory[17] = 32'h00008067;
end

endmodule