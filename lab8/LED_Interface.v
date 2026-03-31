module LED_Interface(
    input clk,
    input rst,
    input writeEnable,
    input [15:0] writeData,
    output reg [15:0] leds
);

always @(posedge clk or posedge rst) begin
    if (rst)
        leds <= 16'b0;
    else if (writeEnable)
        leds <= writeData;
end

endmodule   