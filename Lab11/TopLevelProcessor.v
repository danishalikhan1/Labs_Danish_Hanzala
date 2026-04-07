`timescale 1ns / 1ps
module TopLevelProcessor(
input clk,
input reset,
output [31:0] debug_out
);
// Internal wires
wire [31:0] PC;
wire [31:0] instruction;
wire [31:0] nextPC;
wire [31:0] readData1, readData2, writeData;
wire [31:0] imm;
wire [31:0] ALU_in2;
wire [3:0] ALUCtrl;
wire [31:0] ALUResult;
wire zero;
wire [31:0] memReadData;
wire RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Branch;
wire [1:0] ALUOp;
wire [31:0] PC_plus4, branchAddr;
wire PCSrc;
ProgramCounter pc_inst(
.clk(clk),
.reset(reset),
.nextPC(nextPC),
.PC(PC)
);
InstructionMemory imem(
.addr(PC),
.instr(instruction)
);
ControlUnit control_unit(
.opcode(instruction[6:0]),
.RegWrite(RegWrite),
.MemRead(MemRead),
.MemWrite(MemWrite),
.MemtoReg(MemtoReg),
.ALUSrc(ALUSrc),
.Branch(Branch),
.ALUOp(ALUOp)
);
RegisterFile rf(
.clk(clk),
.reset(reset),
.writeEnable(RegWrite),
.readReg1(instruction[19:15]),
.readReg2(instruction[24:20]),
.writeReg(instruction[11:7]),
.writeData(writeData),
.readData1(readData1),
.readData2(readData2)
);
immGen ig(
.instr(instruction),
.imm(imm)
);
ALUControl alu_control(
.ALUOp(ALUOp),
.funct7(instruction[31:25]),
.funct3(instruction[14:12]),
.ALUControl(ALUCtrl)
);
mux2 alu_mux(
.in0(readData2),
.in1(imm),
.sel(ALUSrc),
.out(ALU_in2)
);
oneBit_Alu alu(
.A(readData1),
.B(ALU_in2),
.ALUControl(ALUCtrl),
.ALUResult(ALUResult),
.Zero(zero)
);
DataMemory dmem(
.clk(clk),
.MemRead(MemRead),
.MemWrite(MemWrite),
.address(ALUResult[8:0]),
.writeData(readData2),
.readData(memReadData)
);
assign writeData = MemtoReg ? memReadData : ALUResult;
pcAdder add4(
.PC(PC),
.PC_plus4(PC_plus4)
);
branchAdder badd(
.PC(PC),
.imm(imm),
.branchAddr(branchAddr)
);
assign PCSrc = Branch & zero;
mux2 pc_mux(
.in0(PC_plus4),
.in1(branchAddr),
.sel(PCSrc),
.out(nextPC)
);
assign debug_out = ALUResult;
endmodule
