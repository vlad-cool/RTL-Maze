// by Aleksandr
// 10x15 tiles scene with 32x32 tiles.
// Draw walls and food. Should be started after tft_init finished.
// tft_dc always = 1(DATA)

module scene_exhibitor
(
    input wire clk,
    input wire rst,
    input wire tft_busy,
    input wire enable,
    input wire[159:0] h_walls,
    input wire[164:0] v_walls,

    output reg[7:0] tft_data,
    output reg tft_transmit,
    output wire busy
);

localparam HALF_TILE_SIZE = 16;
localparam MAX_X_INDEX = 320 + HALF_TILE_SIZE;
localparam MAX_Y_INDEX = 480 + HALF_TILE_SIZE;

reg[8:0] x_index;
reg[8:0] y_index;
reg[1:0] color_index;

assign busy = (x_index < MAX_X_INDEX) & (y_index < MAX_Y_INDEX) & enable;

wire[7:0] wall_color[2:0];
assign wall_color[0] = 8'h3a;
assign wall_color[1] = 8'h7b;
assign wall_color[2] = 8'hd5;

wire wall_value;
wall_layout layout
(
    .x(x_index[4:1]), //double size walls grid
    .y(y_index[4:1]), //double size walls grid
    .left(x_index[8:5] == 0 ? 0 : h_walls[y_index[8:5] * 10 + x_index[8:5] - 1]),
    .top(y_index[8:5] == 0 ? 0 : v_walls[y_index[8:5] * 11 + x_index[8:5] - 11]),
    .right(x_index[8:5] == 9 ? 0 : h_walls[y_index[8:5] * 10 + x_index[8:5]]),
    .bottom(y_index[8:5] == 14 ? 0 : v_walls[y_index[8:5] * 11 + x_index[8:5]]),
    .value(wall_value)
);

always @(posedge clk)
begin
    if(rst)
    begin
        color_index <= 0;
        x_index <= HALF_TILE_SIZE;
        y_index <= HALF_TILE_SIZE;
        tft_transmit <= 0;
    end
    else if(color_index == 3)
    begin
        color_index <= 0;
        x_index <= x_index + 1;
    end
    else if(x_index == MAX_X_INDEX)
    begin
        x_index <= HALF_TILE_SIZE;
        y_index <= y_index + 1;
    end
    else if(busy && (~tft_busy) & (~tft_transmit))
    begin
        tft_transmit <= 1;
        if(wall_value)
            tft_data <= wall_color[color_index];
        else
            tft_data <= 0; //black background
        color_index <= color_index + 1;
    end
    else
    begin
        tft_transmit <= 0;
    end
end

endmodule
