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

localparam SCENE_WIDTH = 320;
localparam SCENE_HEIGHT = 480;

reg[8:0] x_index;
reg[8:0] y_index;
reg[1:0] color_index;

assign tft_dc = 1;  //data
assign busy = (x_index < SCENE_WIDTH) & (y_index < SCENE_HEIGHT) & enable;

wire[7:0] wall_color[2:0];
assign wall_color[0] = 0;
assign wall_color[1] = 8'h10;
assign wall_color[2] = 8'hfe;
wire[7:0] background_color[2:0];
assign background_color[0] = 0;
assign background_color[1] = 0;
assign background_color[2] = 0;

wire wall_value;
wall_layout layout
(
    .x(x_index[4:1] + 8), //shift wall grid
    .y(y_index[4:1] + 8), //shift wall grid
    .left((x_index > 8) & (x_index < 312)),
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
    else if(x_index == SCENE_WIDTH)
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
