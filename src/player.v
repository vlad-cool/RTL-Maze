// by Vladislav

module player
#(
    parameter size = 22
)
(
    input wire rst,
    input wire clk,
    input wire enable,

    input wire tft_busy,
    output reg tft_dc,
    output reg[7:0] tft_data,
    output reg tft_transmit,

    output reg busy,

    output wire debug,

    input wire[8:0] x,
    input wire[8:0] y,
    input wire draw
);

reg [$clog2(size * size) - 1 : 0]pixel_counter;
reg [3:0]selection_counter;

reg [7:0] counter;

// wire [15:0] x_min_old, y_min_old, x_max_old, y_max_old;
reg [8:0] x_min, y_min, x_max, y_max;

// assign x_min_new = x_new;
// assign y_min_new = y_new;
// assign x_max_new = x_new + size - 1;
// assign y_max_new = y_new + size - 1;

reg [8:0]x_new, y_new;

reg drawing_background;

assign debug = drawing_background;

wire [483:0]sprite[2:0];

assign sprite[0] = {
22'b0000000111111110000000,
22'b0000011111111111100000,
22'b0000111111111111110000,
22'b0001111111111111111000,
22'b0011111111111111111100,
22'b0111111111111101111110,
22'b0111111111111111111110,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b0111111111111111111110,
22'b0111111111111111111110,
22'b0011111111111111111100,
22'b0001111111111111111000,
22'b0000111111111111110000,
22'b0000011111111111100000,
22'b0000000111111110000000,
};

assign sprite[1] = {
22'b0000000000000000000000,
22'b0000010000000000100000,
22'b0000111000000001110000,
22'b0001111000000001111000,
22'b0011111100000011111100,
22'b0111111100000011111110,
22'b0111111110000111111110,
22'b1111111110000111011111,
22'b1111111111001111111111,
22'b1111111111001111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b0111111111111111111110,
22'b0111111111111111111110,
22'b0011111111111111111100,
22'b0001111111111111111000,
22'b0000111111111111110000,
22'b0000011111111111100000,
22'b0000000111111110000000,
};

assign sprite[2] = {
22'b0000000000000000000000,
22'b0000000000000000000000,
22'b0000000000000000000000,
22'b0000000000000000000000,
22'b0011000000000000001100,
22'b0111100000000000011110,
22'b0111110000000000111110,
22'b1111111000000001111111,
22'b1111111100000011111111,
22'b1111111110000111111111,
22'b1111111111001111110111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b1111111111111111111111,
22'b0111111111111111111110,
22'b0111111111111111111110,
22'b0011111111111111111100,
22'b0001111111111111111000,
22'b0000111111111111110000,
22'b0000011111111111100000,
22'b0000000111111110000000,
};

always @(posedge clk) begin
    if (rst) begin
        selection_counter <= 0;
        pixel_counter <= 0;
        busy <= 0;
        
        counter <= 0;
        
        x_new <= 5;
        y_new <= 5;

        drawing_background <= 0;
    end
    else if (enable) begin
        if (!busy) begin
            if (draw) begin
                selection_counter <= 1;

                if (x_new == x && y_new == y) begin
                    x_min <= x_new;
                    x_max <= x_new + size - 1;
                    y_min <= y_new;
                    y_max <= y_new + size - 1;
                    drawing_background <= 0;
                end
                else if (x_new == x) begin
                    x_min <= x_new;
                    x_max <= x_new + size - 1;
                    if (y_new < y) begin
                        y_min <= y_new;
                        y_max <= y - 1;
                    end
                    else begin
                        y_min <= size + y + 1;
                        y_max <= size + y_new - 1;
                    end
                    drawing_background <= 1;
                end
                else if (y_new == y) begin
                    y_min <= y_new;
                    y_max <= y_new + size - 1;
                    if (x_new < x) begin
                        x_min <= x_new;
                        x_max <= x - 1;
                    end
                    else begin
                        x_min <= size + x + 1;
                        x_max <= size + x_new - 1;
                    end
                    drawing_background <= 1;
                end
                else begin
                    x_min <= x_new;
                    x_max <= x_new + size - 1;
                    y_min <= y_new;
                    y_max <= y_new + size - 1;
                    drawing_background <= 1;
                end

                x_new <= x;
                y_new <= y;
                busy <= 1;

                pixel_counter <= 0;
            end
        end
        else if (~tft_busy & ~tft_transmit) begin
            if (selection_counter > 0 & selection_counter < 12) begin
                case(selection_counter)
                    1:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2a};
                    2:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 7'b0, x_min[8:8]};
                    3:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1,       x_min[7:0]};
                    4:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 7'b0, x_max[8:8]};
                    5:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1,       x_max[7:0]};
                    6:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2b};
                    7:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 7'b0, y_min[8:8]};
                    8:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1,       y_min[ 7:0]};
                    9:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 7'b0, y_max[8:8]};
                    10: {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1,       y_max[ 7:0]};
                    11: {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2c};
                endcase
            
                selection_counter <= selection_counter + 1;
            end
            else if (selection_counter == 12 && pixel_counter != size * size) begin
                if (drawing_background) begin
                    {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 8'h00};
                end
                else begin
                    {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, sprite[0][pixel_counter] ? (counter != 2 ? 8'hff : 8'h00) : 8'h00};
                    // {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 1 ? (counter != 2 ? 8'hff : 8'h00) : 8'h00};
                    // {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 8'hff};
                end
                counter <= counter == 2 ? 0 : counter + 1;
                pixel_counter <= counter == 2 ? pixel_counter + 1 : pixel_counter;
                // busy <= pixel_counter == size * size ? 0 : 1;
            end
            else if (pixel_counter == size * size) begin
                if (drawing_background) begin
                    drawing_background <= 0;
                    x_min <= x_new;
                    y_min <= y_new;
                    x_max <= x_new + size - 1;
                    y_max <= y_new + size - 1;
                    selection_counter <= 1;
                    pixel_counter <= 0;
                end
                else
                begin
                    drawing_background <= 1;
                    busy <= 0;
                end
            end
        end
        else begin
            tft_transmit <= 0;
        end
    end
end

endmodule
