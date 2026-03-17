module RegisterFile (
input clk,
input reset,
input writeEnable,
input [4:0] readReg1,
input [4:0] readReg2,
input [4:0] writeReg,
input [31:0] writeData,
output [31:0] readData1,
output [31:0] readData2
);
reg [31:0] regs [31:0];
integer i;
always @(posedge clk) begin
if (reset) begin
for (i = 0; i < 32; i = i + 1)
regs[i] <= 32'b0;
end
else begin
if (writeEnable && writeReg != 5'd0)
regs[writeReg] <= writeData;
end
end
assign readData1 = (readReg1 == 5'd0) ? 32'b0 : regs[readReg1];
assign readData2 = (readReg2 == 5'd0) ? 32'b0 : regs[readReg2];
endmodule