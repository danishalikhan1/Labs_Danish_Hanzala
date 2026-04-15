module oneBit_Alu (
input [31:0] A,
input [31:0] B,
input [3:0] ALUControl,
output reg [31:0] ALUResult,
output Zero
);
always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = A + B;          // ADD / ADDI
            4'b0001: ALUResult = A - B;          // SUB / BEQ
            4'b0010: ALUResult = A & B;          // AND
            4'b0011: ALUResult = A | B;          // OR
            4'b0100: ALUResult = A ^ B;          // XOR
            4'b0101: ALUResult = A << B[4:0];    // SLL (Shift Left Logical)
            4'b0110: ALUResult = A >> B[4:0];    // SRL (Shift Right Logical)
            4'b0111: ALUResult = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // SLT (Set Less Than)
            default: ALUResult = 32'hDEADBEEF;   // Debug value: makes it obvious if control logic is wrong
        endcase
    end
assign Zero = (ALUResult == 32'b0);
endmodule