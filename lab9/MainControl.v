module MainControl(
    input [6:0] opcode,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg MemtoReg,
    output reg Branch,
    output reg [1:0] ALUOp
);

always @(*) begin

    
    RegWrite = 0;
    MemRead = 0;
    MemWrite = 0;
    ALUSrc = 0;
    MemtoReg = 0;
    Branch = 0;
    ALUOp = 2'b00;

    case(opcode)

        
        7'b0110011: begin
            RegWrite = 1;
            ALUSrc = 0;
            ALUOp = 2'b10;
        end

        
        7'b0000011: begin
            RegWrite = 1;
            MemRead = 1;
            MemtoReg = 1;
            ALUSrc = 1;
            ALUOp = 2'b00;
        end

        
        7'b0100011: begin
            MemWrite = 1;
            ALUSrc = 1;
            MemtoReg = 1'bx;
            ALUOp = 2'b00;
        end

        
        7'b1100011: begin
            Branch = 1;
            MemtoReg = 1'bx;
            ALUOp = 2'b01;
        end

        
        7'b0010011: begin
            RegWrite = 1;
            ALUSrc = 1;
            ALUOp = 2'b00;
        end

    endcase
end

endmodule