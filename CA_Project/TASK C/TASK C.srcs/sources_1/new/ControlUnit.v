module ControlUnit(
    input [6:0] opcode,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg ALUSrc,
    output reg Branch,
    output reg [1:0] ALUOp,
    output reg jump
);

always @(*) begin
    // Default values to prevent latches
    RegWrite = 0; MemRead = 0; MemWrite = 0; MemtoReg = 0;
    ALUSrc = 0; Branch = 0; ALUOp = 2'b00; jump = 0;
    case(opcode)

        7'b0110011: begin // R-type
            RegWrite = 1;
            ALUSrc   = 0;
            MemtoReg = 0;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 0;
            ALUOp    = 2'b10;
            jump = 0;
        end
        
        7'b0010011: begin // addi, ori
            RegWrite = 1;
            ALUSrc   = 1; // Use immediate
            MemtoReg = 0;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 0;
            ALUOp    = 2'b11; // Force ALU to ADD
            jump = 0;
        end

        7'b0000011: begin // lw
            RegWrite = 1;
            ALUSrc   = 1;
            MemtoReg = 1;
            MemRead  = 1;
            MemWrite = 0;
            Branch   = 0;
            ALUOp    = 2'b00;
            jump = 0;
        end

        7'b0100011: begin // sw
            RegWrite = 0;
            ALUSrc   = 1;
            MemtoReg = 0;
            MemRead  = 0;
            MemWrite = 1;
            Branch   = 0;
            ALUOp    = 2'b00;
            jump = 0;
        end

        7'b1100011: begin // beq
            RegWrite = 0;
            ALUSrc   = 0;
            MemtoReg = 0;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 1;
            ALUOp    = 2'b01;
            jump = 0;
        end
        
        7'b0110111: begin // lui (U_Type)
            RegWrite = 1;
            ALUSrc   = 1;
            MemtoReg = 0;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 0;
            ALUOp    = 2'b00;
        end
        
        7'b1101111: begin // jal (J-type)
            RegWrite = 1;
            ALUSrc   = 0;
            MemtoReg = 0;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 0;
            ALUOp    = 2'b01;
            jump = 1;
        end
        7'b1100111: begin // jalr (I-type Jump) -> ADDED THIS BLOCK
            RegWrite = 1;
            ALUSrc = 1;
            MemtoReg = 0;
            MemRead = 0;
            MemWrite = 0;
            Branch = 0;
            ALUOp = 2'b11; 
            jump = 1;
        end
        default: begin
            RegWrite = 0;
            ALUSrc   = 0;
            MemtoReg = 0;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 0;
            ALUOp    = 2'b00; // 11 forces ALU to ADD (rs1 + imm)
            jump = 1;
        end
        
    endcase
end

endmodule