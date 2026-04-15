module TopLevelProcessor(
    input clk,              
    input clk_fast,         
    input reset,            
    output [31:0] debug_out,
    output [6:0] seg,       
    output [3:0] an         
);

    wire [31:0] PC, instruction, nextPC;
    wire [31:0] readData1, readData2, writeData, imm, ALU_in2, ALUResult, memReadData;
    wire [3:0] ALUCtrl;
    wire zero, RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Branch, jump;
    wire [1:0] ALUOp;
    wire [31:0] PC_plus4, branchAddr;
    wire PCSrc;

    // --- SEGMENT DISPLAY REGISTER ---
    reg [31:0] seg_reg; 
    // Change your mapping logic to this:   
    always @(posedge clk or posedge reset) begin
        if (reset) 
            seg_reg <= 32'b0;
        else if (MemWrite && (ALUResult == 32'd12)) // Only check the last 4 bits
            seg_reg <= readData2;
    end

    // --- DECIMAL CONVERSION ---
    wire [3:0] tens = (seg_reg[7:0] / 10);
    wire [3:0] ones = (seg_reg[7:0] % 10);
    wire [31:0] decimal_display = {24'b0, tens, ones};
    // --- CORE MODULES ---
    ProgramCounter pc_inst(.clk(clk), .reset(reset), .nextPC(nextPC), .PC(PC));
    InstructionMemory imem(.addr(PC), .instr(instruction));
    
    ControlUnit cu(.opcode(instruction[6:0]), .RegWrite(RegWrite), .MemRead(MemRead), 
                   .MemWrite(MemWrite), .MemtoReg(MemtoReg), .ALUSrc(ALUSrc), 
                   .Branch(Branch), .ALUOp(ALUOp), .jump(jump));

    RegisterFile rf(.clk(clk), .reset(reset), .writeEnable(RegWrite),
                    .readReg1(instruction[19:15]), .readReg2(instruction[24:20]),
                    .writeReg(instruction[11:7]), .writeData(writeData),
                    .readData1(readData1), .readData2(readData2));

    immGen ig(.instr(instruction), .imm(imm));
    ALUControl ac(.ALUOp(ALUOp), .funct7(instruction[31:25]), .funct3(instruction[14:12]), .ALUControl(ALUCtrl));
    mux2 amux(.in0(readData2), .in1(imm), .sel(ALUSrc), .out(ALU_in2));

    oneBit_Alu alu_inst(.A(readData1), .B(ALU_in2), .ALUControl(ALUCtrl), 
                        .ALUResult(ALUResult), .Zero(zero));

    DataMemory dmem(.clk(clk), .MemRead(MemRead), .MemWrite(MemWrite), 
                    .address(ALUResult[8:0]), .writeData(readData2), .readData(memReadData));
                    
    pcAdder add4(.PC(PC), .PC_plus4(PC_plus4));
    branchAdder badd(.PC(PC), .imm(imm), .branchAddr(branchAddr));
    
    // --- BRANCH AND JUMP LOGIC ---
    wire [2:0] funct3 = instruction[14:12];
    wire is_beq = (funct3 == 3'b000);
    wire is_bne = (funct3 == 3'b001);
    wire is_blt = (funct3 == 3'b100);

   wire branch_taken = Branch & (
        (is_beq & zero)          |   // beq
        (is_bne & ~zero)         |   // bne
        (is_blt & ALUResult[31]) );  // blt (signed: result negative ? A < B)
    
    // Check if it is jalr
    wire is_jalr = (instruction[6:0] == 7'b1100111);
    
    // If jalr, jump to the ALU calculated address. Otherwise, jump to the standard branchAddr (PC+imm)
    wire [31:0] jumpTarget = is_jalr ? ALUResult : branchAddr;
    
    
    assign nextPC = (jump | branch_taken) ? branchAddr : PC_plus4;


    // --- ADVANCED WRITEBACK LOGIC ---
    wire is_lui = (instruction[6:0] == 7'b0110111);
    wire is_jal = (instruction[6:0] == 7'b1101111);

    // If LUI -> Write Imm directly. If JAL -> Write PC+4. Else -> Standard MemToReg
    assign writeData = is_lui ? imm : 
                       (is_jal | is_jalr) ? PC_plus4 : 
                       (MemtoReg ? memReadData : ALUResult);

    assign debug_out = PC; 

    // Changed back to decimal_display for FPGA verification
    SevenSeg_Driver display_unit(
        .clk(clk_fast), 
        .data(decimal_display), 
        .seg(seg), 
        .an(an)
    );

endmodule