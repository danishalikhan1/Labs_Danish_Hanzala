module top (
input wire clk,
input wire rst,
input wire [15:0] switches,
output wire [15:0] leds_out
);
wire [15:0] count;
// FSM instance
fsm1 fsm_inst (
.clk(clk),
.rst(rst),
.switch_value(switches),
.count(count)
);
// LEDs reflect counter value
assign leds_out = count;
endmodule