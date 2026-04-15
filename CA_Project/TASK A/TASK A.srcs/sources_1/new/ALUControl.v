module ALUControl(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] ALUControl
);

always @(*) begin
    case(ALUOp)
        // ALUOp 00: Load, Store, and ADDI (Force ADD)
        2'b00: ALUControl = 4'b0000; 

        // ALUOp 01: Branch Equal (Force SUB for comparison)
        2'b01: ALUControl = 4'b0001; 

        // ALUOp 10: R-Type Arithmetic
        2'b10: begin
            case({funct7, funct3})
                {7'b0000000, 3'b000}: ALUControl = 4'b0000; // ADD
                {7'b0100000, 3'b000}: ALUControl = 4'b0001; // SUB
                {7'b0000000, 3'b111}: ALUControl = 4'b0010; // AND
                {7'b0000000, 3'b110}: ALUControl = 4'b0011; // OR
                {7'b0000000, 3'b100}: ALUControl = 4'b0100; // XOR
                default: ALUControl = 4'b0000;
            endcase
        end

        default: ALUControl = 4'b0000;
    endcase
end

endmodule