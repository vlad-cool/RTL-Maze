// by Vladislav

module player
#(
    parameter size = 20
)
(
    input wire rst,
    input wire clk,
    input wire[8:0] x,
    input wire[8:0] y,
    input wire enable,

    input wire tft_busy,
    output reg tft_dc,
    output reg[7:0] tft_data,
    output reg tft_transmit,

    output reg busy
);

reg [$clog2(size * size) - 1 : 0]pixel_counter;
reg [3:0]selection_counter;

reg [7:0] counter;

wire [15:0] x_min, y_min, x_max, y_max;

assign x_min = x;
assign y_min = y;
assign x_max = x + size - 1;
assign y_max = y + size - 1;

always @(posedge clk) begin
    if (rst) begin
        selection_counter <= 0;
        pixel_counter <= 0;
        busy <= 0;

        counter <= 0;
    end
    else if (enable) begin
        if (!busy) begin
            selection_counter <= selection_counter + 1;
            busy <= 1;
        end
        else if (~tft_busy & ~tft_transmit) begin
            if (selection_counter > 0 && selection_counter < 12) begin
                case(selection_counter)
                    // 1:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2a};
                    // 2:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 8'b0}; // TODO FIX LATER
                    // 3:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, x & 8'hff};
                    // 4:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 8'b0};
                    // 5:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, (x + size - 1) & 8'hff};

                    // 6:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2b};
                    // 7:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 8'b0};
                    // 8:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, y & 8'hff};
                    // 9:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 8'b0};
                    // 10: {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, (y + size - 1) & 8'hff};

                    // 11: {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2c};
                    1:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2a};
                    2:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, x_min[15:8]};
                    3:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, x_min[ 7:0]};
                    4:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, x_max[15:8]};
                    5:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, x_max[ 7:0]};
                    6:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2b};
                    7:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, y_min[15:8]};
                    8:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, y_min[ 7:0]};
                    9:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, y_max[15:8]};
                    10: {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, y_max[ 7:0]};
                    11: {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2c};
                endcase
            
                selection_counter <= selection_counter + 1;
            end
            else if (selection_counter == 12) begin
                {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, counter != 2 ? 8'hff : 8'h00};
                counter <= counter == 2 ? 0 : counter + 1;
                pixel_counter <= counter == 2 ? pixel_counter + 1 : pixel_counter;
                busy <= pixel_counter == size * size ? 0 : 1;
            end
        end
        else begin
            tft_transmit <= 0;
        end
    end
end

endmodule
