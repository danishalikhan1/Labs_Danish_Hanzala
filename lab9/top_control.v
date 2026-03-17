module top_control (
    input clk,
    input rst,
    input [15:0] SW,
    output reg [9:0] LED
);


reg [1:0] state;
parameter IDLE = 2'b00;
parameter READ = 2'b01;
parameter DISPLAY = 2'b10;


reg [6:0] opcode_reg;
reg [2:0] funct3_reg;
reg [6:0] funct7_reg;


wire RegWrite;
wire MemRead;
wire MemWrite;
wire ALUSrc;
wire MemtoReg;
wire Branch;
wire [1:0] ALUOp;
wire [3:0] ALUControl;


always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else begin
        case(state)
            IDLE:    state <= READ;
            READ:    state <= DISPLAY;
            DISPLAY: state <= READ;
            default: state <= IDLE;
        endcase
    end
end


always @(posedge clk) begin
    if (state == READ) begin
        opcode_reg <= SW[6:0];
        funct3_reg <= SW[9:7];
        funct7_reg <= SW[15:10];
    end
end

MainControl MC(
    .opcode(opcode_reg),
    .RegWrite(RegWrite),
    .ALUOp(ALUOp),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .MemtoReg(MemtoReg),
    .Branch(Branch)
);


ALUControl AC(
    .ALUOp(ALUOp),
    .funct3(funct3_reg),
    .funct7(funct7_reg),
    .ALUControl(ALUControl)
);


always @(posedge clk) begin
    if (state == DISPLAY) begin
        LED[0] <= RegWrite;
        LED[1] <= MemRead;
        LED[2] <= MemWrite;
        LED[3] <= ALUSrc;
        LED[4] <= MemtoReg;
        LED[5] <= Branch;
        LED[9:6] <= ALUControl;
    end
end

endmodule