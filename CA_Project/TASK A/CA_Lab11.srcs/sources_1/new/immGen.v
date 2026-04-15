module immGen(
    input [31:0] instr,
    output reg [31:0] imm
);

wire [6:0] opcode = instr[6:0];

always @(*) begin
    case(opcode)

        // I-Type (e.g., lw, addi)
        7'b0000011,
        7'b0010011: begin
            imm = {{20{instr[31]}}, instr[31:20]};
        end

        // S-Type (store)
        7'b0100011: begin
            imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        end

        // B-Type (branch)
        7'b1100011: begin
            imm = {{19{instr[31]}},
                   instr[31],
                   instr[7],
                   instr[30:25],
                   instr[11:8],
                   1'b0};
        end

        default: imm = 32'b0;
    endcase
end

endmodule