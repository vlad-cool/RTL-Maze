// by Vladislav

module dummy_module
(
    input wire clk,
    input wire rst,
    input wire enable,

    input wire tft_busy,
    output reg tft_dc,
    output reg[7:0] tft_data,
    output reg tft_transmit,

    output reg busy

    // OTHER IO
);

endmodule