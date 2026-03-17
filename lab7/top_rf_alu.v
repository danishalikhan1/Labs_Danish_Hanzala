`timescale 1ns / 1ps
module top_rf_alu (
input wire clk,
input wire reset_btn,
input wire [15:0] switches,
output wire [15:0] leds
);
wire debounced_rst;
wire [31:0] readData1, readData2, ALUResult;
reg [31:0] writeData;
reg [4:0] writeReg;
reg writeEnable;
wire Zero;
wire [3:0] ALUControl = switches[3:0];
localparam INIT_X1 = 2'b00,
INIT_X2 = 2'b01,
RUN = 2'b10;
reg [1:0] state, next_state;
debouncer db_rst (.clk(clk), .pbin(reset_btn), .pbout(debounced_rst));
always @(posedge clk) begin
if (debounced_rst) state <= INIT_X1;
else state <= next_state;
end
always @(*) begin
writeEnable = 0;
writeData = 32'b0;
writeReg = 5'b0;
next_state = state;
case (state)
INIT_X1: begin
writeEnable = 1;
writeReg = 5'd1;
writeData = 32'h10101010;
next_state = INIT_X2;
end
INIT_X2: begin
writeEnable = 1;
writeReg = 5'd2;
writeData = 32'h01010101;
next_state = RUN;
end
RUN: begin
writeEnable = switches[15];
writeReg = switches[12:8];
writeData = ALUResult;
next_state = RUN;
end
default: next_state = INIT_X1;
endcase
end
RegisterFile RF (
.clk(clk),
.reset(debounced_rst),
.writeEnable(writeEnable),
.readReg1(5'd1),
.readReg2(5'd2),
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
assign leds[11:0] = ALUResult[11:0];
assign leds[13:12] = 2'b00;
assign leds[14] = Zero;
assign leds[15] = (state == RUN) ? 1'b1 : 1'b0;
endmodule