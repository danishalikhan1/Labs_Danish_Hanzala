`timescale 1ns / 1ps
module testbench();
reg clk;
reg rst;
reg [15:0] switches;
// Outputs
wire [15:0] leds_out;
// Instantiate DUT
top dut (
.clk(clk),
.rst(rst),
.switches(switches),
.leds_out(leds_out)
);
// Clock generation (100 MHz)
always #5 clk = ~clk;
initial begin
// Initial values
clk = 0;
rst = 1;
switches = 16'd0;
// Apply reset
#20;
rst = 0;
// Test case 1: Load 5
#10;
switches = 16'd5;
// Observe countdown
#120;
// Test case 2: Load 3
switches = 16'd3;
#80;
// Test reset during count
switches = 16'd7;
#20;
rst = 1;
#20;
rst = 0;
#100;
$stop;
end
endmodule