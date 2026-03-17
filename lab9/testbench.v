`timescale 1ns/1ps

module testbench;

reg [6:0] opcode;
reg [1:0] ALUOp;
reg [2:0] funct3;
reg [6:0] funct7;

wire RegWrite;
wire MemRead;
wire MemWrite;
wire ALUSrc;
wire MemtoReg;
wire Branch;
wire [1:0] ALUOp_out;
wire [3:0] ALUControl;

// Instantiate Main Control
MainControl mc(
    opcode,
    RegWrite,
    MemRead,
    MemWrite,
    ALUSrc,
    MemtoReg,
    Branch,
    ALUOp_out
);

// Instantiate ALU Control
ALUControl ac(
    ALUOp_out,
    funct3,
    funct7,
    ALUControl
);

initial begin

$dumpfile("control.vcd");
$dumpvars(0,testbench);

// R-type ADD
opcode = 7'b0110011;
funct3 = 3'b000;
funct7 = 7'b0000000;
#10;

// R-type SUB
opcode = 7'b0110011;
funct3 = 3'b000;
funct7 = 7'b0100000;
#10;

// Load
opcode = 7'b0000011;
funct3 = 3'b000;
funct7 = 7'b0000000;
#10;

// Store
opcode = 7'b0100011;
funct3 = 3'b000;
funct7 = 7'b0000000;
#10;

// Branch
opcode = 7'b1100011;
#10;

// ADDI
opcode = 7'b0010011;
funct3 = 3'b000;

#10;

$finish;

end

endmodule