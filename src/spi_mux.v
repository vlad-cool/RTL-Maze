module spi_mux
#(
    parameter SIZE = 1
)
(
    input wire init_enable,
    input wire scene_enable,
    input wire player_enable,

    input wire[SIZE-1:0] init_out,
    input wire[SIZE-1:0] scene_out,
    input wire[SIZE-1:0] player_out,

    output wire[SIZE-1:0] spi_in
);

assign spi_in = ({SIZE{init_enable}} & init_out) |
                ({SIZE{scene_enable}} & scene_out) |
                ({SIZE{player_enable}} & player_out);

endmodule