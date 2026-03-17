module fsm(
    input clk,
    input rst,
    output reg enable
);

reg [1:0] state;

parameter IDLE = 2'b00;
parameter READ = 2'b01;
parameter DISPLAY = 2'b10;

always @(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        case(state)
            IDLE: state <= READ;
            READ: state <= DISPLAY;
            DISPLAY: state <= READ;
        endcase
end

always @(*)
begin
    case(state)
        READ: enable = 1;
        default: enable = 0;
    endcase
end

endmodule