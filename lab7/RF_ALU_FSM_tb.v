`timescale 1ns/1ps

module RF_ALU_FSM_tb;
    reg clk;
    reg reset;
    reg writeEnable;
    reg [4:0] readReg1, readReg2, writeReg;
    reg [31:0] writeData;
    wire [31:0] readData1, readData2;
    reg [3:0] ALUControl;
    wire [31:0] ALUResult;
    wire Zero;

    always #5 clk = ~clk;

    RegisterFile RF (
        .clk(clk),
        .reset(reset),
        .writeEnable(writeEnable),
        .readReg1(readReg1),
        .readReg2(readReg2),
        .writeReg(writeReg),
        .writeData(writeData),
        .readData1(readData1),
        .readData2(readData2)
    );

    oneBit_Alu ALU (
        .A(readData1),
        .B(readData2),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    reg [3:0] state;
    reg [3:0] op_index;

    parameter IDLE        = 4'd0,
              WRITE_CONST = 4'd1,
              READ        = 4'd2,
              ALU_OP      = 4'd3,
              WRITE_BACK  = 4'd4,
              BEQ_TEST    = 4'd5,
              DONE        = 4'd6;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            op_index <= 0;
            writeEnable <= 0;
        end else begin
            case (state)
                IDLE: state <= WRITE_CONST;
                
                WRITE_CONST: begin
                    writeEnable <= 1;
                    case (op_index)
                        0: begin writeReg <= 5'd1; writeData <= 32'h10101010; end
                        1: begin writeReg <= 5'd2; writeData <= 32'h01010101; end
                        2: begin writeReg <= 5'd3; writeData <= 32'h00000005; end
                        default: begin
                            writeEnable <= 0;
                            op_index <= 0;
                            state <= READ;
                        end
                    endcase
                    op_index <= op_index + 1;
                end

                READ: begin
                    readReg1 <= 5'd1;
                    readReg2 <= 5'd2;
                    state <= ALU_OP;
                end

                ALU_OP: begin
                    case (op_index)
                        4: ALUControl <= 4'b0000; // ADD
                        5: ALUControl <= 4'b0001; // SUB
                        6: ALUControl <= 4'b0010; // AND
                        7: ALUControl <= 4'b0011; // OR
                        8: ALUControl <= 4'b0100; // XOR
                        9: ALUControl <= 4'b0101; // SLL
                        10: ALUControl <= 4'b0110; // SRL
                        default: state <= BEQ_TEST;
                    endcase
                    if (op_index <= 10) state <= WRITE_BACK;
                end

                WRITE_BACK: begin
                    writeEnable <= 1;
                    writeReg <= op_index;
                    writeData <= ALUResult;
                    op_index <= op_index + 1;
                    state <= READ;
                end

                BEQ_TEST: begin
                    writeEnable <= 0;
                    readReg1 <= 5'd1;
                    readReg2 <= 5'd1;
                    ALUControl <= 4'b0001;
                    if (Zero) begin
                        writeEnable <= 1;
                        writeReg <= 5'd15;
                        writeData <= 32'd1;
                    end
                    state <= DONE;
                end

                DONE: writeEnable <= 0;
            endcase
        end
    end

    initial begin
        clk = 0;
        reset = 1;
        #20 reset = 0;
        #500 $stop;
    end
endmodule