`timescale 1ns/1ps
module tb_TopLevelProcessor;
reg clk;
reg reset;
// Instantiate DUT
TopLevelProcessor uut (
.clk(clk),
.reset(reset)
);
// Clock generation (10ns period)
always #5 clk = ~clk;
initial begin
clk = 0;
reset = 1;
#10 reset = 0; // release reset once
#200 $stop; // run simulation
end
endmodule
