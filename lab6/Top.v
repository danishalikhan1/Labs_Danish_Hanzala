`timescale 1ns / 1ps
module Top (
input wire clk,
input wire rst,
input wire [3:0] sw,
output reg [15:0] led
);
wire [31:0] A = 32'h10101010;
wire [31:0] B = 32'h01010101;
wire [31:0] alu_out;
wire zero_flag;
reg [3:0] alu_ctrl_reg;
ALU alu_inst (
.A(A),
.B(B),
.ALUControl(alu_ctrl_reg),
.ALUResult(alu_out),
.Zero(zero_flag)
);
localparam READ_SW = 1'b0;
localparam DISPLAY = 1'b1;
reg state;
always @(posedge clk or posedge rst) begin
if (rst) begin
state <= READ_SW;
alu_ctrl_reg <= 4'b0000;
led <= 16'b0;
end else begin
case (state)
READ_SW: begin
alu_ctrl_reg <= sw;
state <= DISPLAY;
end
DISPLAY: begin
led[14:0] <= alu_out[14:0];
led[15] <= zero_flag;
state <= READ_SW;
end
endcase
end
end
endmodule