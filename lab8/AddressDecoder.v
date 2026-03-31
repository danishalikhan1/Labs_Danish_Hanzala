module AddressDecoder(
    input [9:8] deviceSelect,
    input readEnable,
    input writeEnable,

    output DataMemRead,
    output DataMemWrite,
    output LEDWrite,
    output SwitchReadEnable
);

    assign DataMemRead      = (deviceSelect == 2'b00) & readEnable;
    assign DataMemWrite     = (deviceSelect == 2'b00) & writeEnable;

    assign LEDWrite         = (deviceSelect == 2'b01) & writeEnable;

    assign SwitchReadEnable = (deviceSelect == 2'b10) & readEnable;

endmodule