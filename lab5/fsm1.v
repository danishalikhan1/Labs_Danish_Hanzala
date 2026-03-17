module fsm1(
input wire clk,
input wire rst,
input wire [15:0] switch_value,
output reg [15:0] count
);
// -------------------------
// State encoding
// -------------------------
parameter S0_IDLE = 2'd0;
parameter S1_LOAD = 2'd1;
parameter S2_COUNTDOWN = 2'd2;
reg [1:0] state, next_state;
// -------------------------
// STATE REGISTER
// -------------------------
always @(posedge clk or posedge rst) begin
if (rst)
state <= S0_IDLE;
else
state <= next_state;
end
// -------------------------
// NEXT STATE LOGIC
// -------------------------
always @(*) begin
next_state = state;
case (state)
S0_IDLE: begin
if (switch_value != 16'd0)
next_state = S1_LOAD;
end
S1_LOAD: begin
next_state = S2_COUNTDOWN;
end
S2_COUNTDOWN: begin
if (count == 16'd0)
next_state = S0_IDLE;
end
default: begin
next_state = S0_IDLE;
end
endcase
end
// -------------------------
// COUNTER LOGIC
// -------------------------
always @(posedge clk or posedge rst) begin
if (rst)
count <= 16'd0;
else begin
case (state)
S0_IDLE: begin
count <= 16'd0;
end
S1_LOAD: begin
count <= switch_value; // latch switches
end
S2_COUNTDOWN: begin
if (count > 0)
count <= count - 1;
end
endcase
end
end
endmodule