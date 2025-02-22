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
    input wire[299:0] food,

    output wire tft_dc,
    output reg[7:0] tft_data,
    output reg tft_transmit,
    output wire busy
);

localparam HALF_TILE_SIZE = 16;
localparam WIDTH = 320;
localparam HEIGHT = 480;

// original(food) grid
reg[8:0] x_index;
reg[8:0] y_index;
reg[1:0] color_index;

// walls grid
wire[8:0] x_shifted;
wire[8:0] y_shifted;
assign x_shifted = x_index + HALF_TILE_SIZE;
assign y_shifted = y_index + HALF_TILE_SIZE;

// gradient walls
wire[11:0] gradient_index;
assign gradient_index = ({1'h0, x_index} << 1) + x_index + ({1'h0, y_index} << 1); // 3x + 2y
wire[7:0] wall_color;
assign wall_color = color_index == 0 ? 8'h78 - gradient_index[11:4] : 
                        color_index == 1 ? gradient_index[11:4] : 8'ha5;

// base output
assign tft_dc = 1;
assign busy = (y_index < HEIGHT) & enable;

// food colors, array is 1D to support icarus verilog
wire[7:0] food_colors[11:0]; // index = {color_id, food_value}
assign food_colors[{2'd0, 2'd1}] = 8'hff;
assign food_colors[{2'd1, 2'd1}] = 8'ha5;
assign food_colors[{2'd2, 2'd1}] = 8'h00;
assign food_colors[{2'd0, 2'd2}] = 8'hff;
assign food_colors[{2'd1, 2'd2}] = 8'hc0;
assign food_colors[{2'd2, 2'd2}] = 8'hcb;
assign food_colors[{2'd0, 2'd3}] = 8'hff;
assign food_colors[{2'd1, 2'd3}] = 8'h00;
assign food_colors[{2'd2, 2'd3}] = 8'h00;

// convert y coord to 1D array index parts
wire[7:0] line;
assign line = ({3'h0, y_index[8:5]} << 3) + ({3'h0, y_index[8:5]} << 1);
wire[7:0] line_shifted;
assign line_shifted = ({3'h0, y_shifted[8:5]} << 3) + ({3'h0, y_shifted[8:5]} << 1);

wire wall_value;
wall_layout w_layout
(
    .x(x_shifted[4:1]), // double size walls grid
    .y(y_shifted[4:1]), // double size walls grid
    .left(x_shifted[8:5] == 0 ? 0 : h_walls[line_shifted + x_shifted[8:5] - 1]),
    .top(y_shifted[8:5] == 0 ? 0 : v_walls[line_shifted + y_shifted[8:5] + x_shifted[8:5] - 11]),
    .right(x_shifted[8:5] == 10 ? 0 : h_walls[line_shifted + x_shifted[8:5]]),
    .bottom(y_shifted[8:5] == 15 ? 0 : v_walls[line_shifted + y_shifted[8:5] + x_shifted[8:5]]),
    .value(wall_value)
);

wire[1:0] food_value;
food_layout f_layout
(
    .x(x_index[4:1]), // double size walls grid
    .y(y_index[4:1]), // double size walls grid
    .type({food[{line + x_index[8:5], 1'b1}], food[{line + x_index[8:5], 1'b0}]}),
    .value(food_value)
);

wire exceeded_x_index;
assign exceeded_x_index = (x_index == WIDTH);
wire ready;
assign ready = busy & (~tft_busy) & (~tft_transmit) & (~exceeded_x_index);

always @(posedge clk)
begin
    if(rst)
        color_index <= 0;
    else if(ready)
        color_index <= color_index == 2 ? 0 : color_index + 1;
end

always @(posedge clk)
begin
    if(rst)
        x_index <= 0;
    else if(exceeded_x_index)
        x_index <= 0;
    else if(ready)
        x_index <= x_index + (color_index == 2 ? 1 : 0);
end

always @(posedge clk)
begin
    if(rst)
        y_index <= 0;
    else
        y_index <= y_index + exceeded_x_index;
end

always @(posedge clk)
begin
    if(rst)
        tft_transmit <= 0;
    else
        tft_transmit <= ready;
end

always @(posedge clk)
begin
    if(food_value)
        tft_data <= food_colors[{color_index, food_value}];
    else if(wall_value)
        tft_data <= wall_color;
    else
        tft_data <= 0; // black background
end

endmodule
