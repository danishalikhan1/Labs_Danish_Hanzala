module InstructionMemory(
    input [31:0] addr,
    output [31:0] instr
);

reg [31:0] memory [0:255];  // 256 instructions

assign instr = memory[addr[9:2]]; // word-aligned

initial begin
    // 0: addi x5, x0, 15 (PC 0)
    // Initialize our countdown at 15
    memory[0] = 32'h00F00293; 

    // 1: sw x5, 12(x0)   (PC 4) <--- LOOP START
    // Store x5 to the display address
    memory[1] = 32'h00502623; 

    // 2: addi x5, x5, -1 (PC 8)
    // x5 = x5 - 1
    memory[2] = 32'hFFF28293; 

    // 3: blt x0, x5, -8  (PC 12)
    // If 0 < x5, branch back to PC 4.
    // This keeps looping as long as x5 is 1, 2, 3... 15.
    // Once x5 hits 0, (0 < 0) is false, and it exits the loop.
    memory[3] = 32'hFE504CE3; 

    // 4: blt x5, x0, 0   (PC 16)
    // Infinite loop "stop". If x5 became -1, then -1 < 0 is true.
    // This traps the CPU at PC 16 so it doesn't run into empty memory.
    memory[4] = 32'h0002CB63; 
end

endmodule