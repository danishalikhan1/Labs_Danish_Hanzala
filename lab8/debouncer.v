module debouncer (
    input  wire clk,
    input  wire btn_in,
    output wire btn_out
);

    reg [15:0] count;
    reg btn_sync_0, btn_sync_1;
    reg btn_debounced;
    reg btn_debounced_delay;

    // 1. Synchronize the asynchronous button input to the clock domain
    always @(posedge clk) begin
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;
    end

    // 2. Debounce by requiring the signal to be stable for 65,536 clock cycles
    always @(posedge clk) begin
        if (btn_sync_1 == btn_debounced) begin
            count <= 0;
        end else begin
            count <= count + 1;
            if (count == 16'hFFFF) begin
                btn_debounced <= btn_sync_1;
            end
        end
    end

    // 3. Edge Detection: Convert the long button press into a single 10ns pulse
    always @(posedge clk) begin
        btn_debounced_delay <= btn_debounced;
    end

    // btn_out is only HIGH for exactly one clock cycle when the button is pressed
    assign btn_out = btn_debounced & ~btn_debounced_delay;

endmodule