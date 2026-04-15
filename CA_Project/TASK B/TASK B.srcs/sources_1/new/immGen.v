module immGen(
    input [31:0] instr,
    output reg [31:0] imm
);

wire [6:0] opcode = instr[6:0];

always @(*) begin
    case(opcode)

        // I-Type (e.g., lw, addi, ori)
        7'b0000011,
        7'b0010011,
        7'b1100111: begin
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
        // U-Type (lui)
        7'b0110111: begin 
            imm = {instr[31:12], 12'b0};
        end    
        
        // J-Type (jal)
        7'b1101111: 
            imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            
        default: imm = 32'b0;
    endcase
end

endmodule