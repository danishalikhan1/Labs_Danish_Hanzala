module TopLevelProcessor(
    input clk,              // CPU Clock
    input clk_fast,         // Fast clock for 7-seg multiplexing
    input reset,            
    output [31:0] debug_out,
    output [6:0] seg,       
    output [3:0] an         
);

    // --- INTERNAL WIRES ---
    wire [31:0] PC, instruction, nextPC;
    wire [31:0] readData1, readData2, writeData, imm, ALU_in2, ALUResult, memReadData;
    wire [3:0] ALUCtrl;
    wire zero, RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Branch;
    wire [1:0] ALUOp;
    wire [31:0] PC_plus4, branchAddr;
    wire PCSrc;

    // --- SEGMENT DISPLAY REGISTER ---
    reg [31:0] seg_reg; 
    always @(posedge clk or posedge reset) begin
        if (reset) 
            seg_reg <= 32'd15; // Initialize display at 15
        // Capture x5 (readData2) when storing to address 12
        else if (MemWrite && (ALUResult[8:0] == 9'h00C)) 
            seg_reg <= readData2;
    end

    // --- DECIMAL CONVERSION ---
    wire [3:0] tens, ones;
    assign tens = (seg_reg[7:0] / 10);
    assign ones = (seg_reg[7:0] % 10);
    wire [31:0] decimal_display = {24'b0, tens, ones};

    // --- ARCHITECTURAL MODULES ---
    ProgramCounter pc_inst(.clk(clk), .reset(reset), .nextPC(nextPC), .PC(PC));
    InstructionMemory imem(.addr(PC), .instr(instruction));
    
    ControlUnit cu(
        .opcode(instruction[6:0]), .RegWrite(RegWrite), .MemRead(MemRead), 
        .MemWrite(MemWrite), .MemtoReg(MemtoReg), .ALUSrc(ALUSrc), 
        .Branch(Branch), .ALUOp(ALUOp)
    );

    RegisterFile rf(
        .clk(clk), .reset(reset), .writeEnable(RegWrite), 
        .readReg1(instruction[19:15]), .readReg2(instruction[24:20]),
        .writeReg(instruction[11:7]), .writeData(writeData),
        .readData1(readData1), .readData2(readData2)
    );

    immGen ig(.instr(instruction), .imm(imm));
    ALUControl ac(.ALUOp(ALUOp), .funct7(instruction[31:25]), .funct3(instruction[14:12]), .ALUControl(ALUCtrl));
    mux2 amux(.in0(readData2), .in1(imm), .sel(ALUSrc), .out(ALU_in2));

    oneBit_Alu alu_inst(
        .A(readData1), .B(ALU_in2), .ALUControl(ALUCtrl), 
        .ALUResult(ALUResult), .Zero(zero)
    );

    DataMemory dmem(
        .clk(clk), .MemRead(MemRead), .MemWrite(MemWrite), 
        .address(ALUResult[8:0]), .writeData(readData2), .readData(memReadData)
    );

    assign writeData = MemtoReg ? memReadData : ALUResult;
    pcAdder add4(.PC(PC), .PC_plus4(PC_plus4));
    branchAdder badd(.PC(PC), .imm(imm), .branchAddr(branchAddr));
    
    // --- BRANCH LOGIC ---
    // This triggers the branch when Branch is high AND ALU result is negative (A < B)
    assign PCSrc = Branch & ALUResult[31];

    mux2 pcmux(.in0(PC_plus4), .in1(branchAddr), .sel(PCSrc), .out(nextPC));

    assign debug_out = PC; 

    SevenSeg_Driver display_unit(
        .clk(clk_fast), .data(decimal_display), .seg(seg), .an(an)
    );

endmodule