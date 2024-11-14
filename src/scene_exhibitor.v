// by Aleksandr
// Draw walls and food. Should be started after tft_init finished.

module scene_exhibitor
(
    input wire clk,
    input wire rst,
    input wire tft_busy,
    input wire enable,
    input wire[629:0] h_walls,
    input wire[619:0] v_walls,

    output wire tft_dc,
    output reg[7:0] tft_data,
    output reg tft_transmit,
    output wire busy
);

localparam H_WALLS = 21;
localparam V_WALLS = 31;

reg[8:0] x_index;
reg[8:0] y_index;
reg[1:0] color_index;

assign tft_dc = 1;  //data
assign busy = (y_index < V_WALLS) & (x_index < H_WALLS) & enable;

wire[7:0] wall_color[2:0];
wall_color[0] = 0;
wall_color[1] = 8'h10;
wall_color[2] = 8'hfe;
wire[7:0] background_color[2:0];
wall_color[0] = 0;
wall_color[1] = 0;
wall_color[2] = 0;

wire wall_value;
wall_layout layout
(
    .x(x_index),
    .y(y_index),
    .left((x_index != 0) & (x_index != 20)),
    .top(1),
    .right(1),
    .bottom(0),
    .value(wall_value)
);

always @(posedge clk)
begin
    if(rst)
    begin
        {y_index, x_index} <= 0;
        tft_transmit <= 0;
    end
    else if(color_index == 3)
    begin
        color_index <= 0;
        x_index <= x_index + 1;
    end
    else if(x_index == 21)
    begin
        x_index <= 0;
        y_index <= y_index + 1;
    end
    else if(busy && (~tft_busy) & (~tft_transmit))
    begin
        tft_transmit <= 1;
        if(wall_value)
            tft_data <= wall_color[color_index];
        else
            tft_data <= background_color[color_index];
        color_index <= color_index + 1;
    end
    else
    begin
        tft_transmit <= 0;
    end
end

endmodule