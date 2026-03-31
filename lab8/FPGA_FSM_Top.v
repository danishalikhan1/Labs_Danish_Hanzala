`timescale 1ns / 1ps

module FPGA_FSM_Top (
    input  wire        clk,
    input  wire        rst,       
    input  wire        step_btn,  
    input  wire [15:0] sw,
    output wire [15:0] led
);

    
    localparam IDLE           = 3'd0;
    localparam READ_SWITCHES  = 3'd1;
    localparam WRITE_DATAMEM  = 3'd2;
    localparam READ_DATAMEM   = 3'd3;
    localparam WRITE_LED      = 3'd4;

    reg [2:0] state, next_state;

    wire step_pulse;
    

    debouncer btn_db (
        .clk(clk),
        .btn_in(step_btn),
        .btn_out(step_pulse)
    );

    
    reg  [31:0] cpu_address;
    reg         cpu_readEnable;
    reg         cpu_writeEnable;
    reg  [31:0] cpu_writeData;
    wire [31:0] cpu_readData;

    reg [31:0] data_reg;

    
    addressDecoderTop memory_system (
        .clk(clk),
        .rst(rst),
        .address(cpu_address),
        .readEnable(cpu_readEnable),
        .writeEnable(cpu_writeEnable),
        .writeData(cpu_writeData),
        .switches(sw),
        .readData(cpu_readData),
        .leds(led)
    );

    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else if (step_pulse) begin
            state <= next_state;
        end
    end

 
    always @(posedge clk) begin
        if (rst) begin
            data_reg <= 32'b0;
        end else if (state == READ_SWITCHES) begin
            data_reg <= cpu_readData; 
        end else if (state == READ_DATAMEM) begin
            data_reg <= cpu_readData; 
        end
    end

   
    always @(*) begin
        next_state      = state;
        cpu_address     = 32'b0;
        cpu_readEnable  = 1'b0;
        cpu_writeEnable = 1'b0;
        cpu_writeData   = 32'b0;

        case (state)
            IDLE: begin
                next_state = READ_SWITCHES;
            end
            
            READ_SWITCHES: begin
                cpu_address    = 32'd600; 
                cpu_readEnable = 1'b1;
                next_state     = WRITE_DATAMEM;
            end
            
            WRITE_DATAMEM: begin
                cpu_address     = 32'd32; 
                cpu_writeData   = data_reg; 
                cpu_writeEnable = 1'b1;
                next_state      = READ_DATAMEM;
            end
            
            READ_DATAMEM: begin
                cpu_address    = 32'd32;  
                cpu_readEnable = 1'b1;
                next_state     = WRITE_LED;
            end
            
            WRITE_LED: begin
                cpu_address     = 32'd300; 
                cpu_writeData   = data_reg;  
                cpu_writeEnable = 1'b1;
                next_state      = READ_SWITCHES; 
            end
        endcase
    end

endmodule