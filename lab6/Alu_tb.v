`timescale 1ns/1ps
module Alu_tb;
reg [31:0] A;
reg [31:0] B;
reg [3:0] ALUControl;
wire [31:0] ALUResult;
wire Zero;
oneBit_Alu uut (
.A(A),
.B(B),
.ALUControl(ALUControl),
.ALUResult(ALUResult),
.Zero(Zero)
);
initial begin
A = 32'd25; B = 32'd17; ALUControl = 4'b0000; #10;
A = 32'd50; B = 32'd20; ALUControl = 4'b0001; #10;
A = 32'hF0F0F0F0; B = 32'h0FF00FF0; ALUControl = 4'b0010; #10;
ALUControl = 4'b0011; #10;
ALUControl = 4'b0100; #10;
A = 32'h00000001;
B = 32'd4;
ALUControl = 4'b0101; #10;
A = 32'h00000010;
B = 32'd4;
ALUControl = 4'b0110; #10;
A = 32'd100; B = 32'd100; ALUControl = 4'b0001; #10;
ALUControl = 4'b1111; #10;
$finish;
end
endmodule