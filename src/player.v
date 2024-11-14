module player
#(
    parameter size = 10
)
(
    input wire rst,
    input wire clk,
    input wire[8:0] x,
    input wire[8:0] y,
    input wire draw,

    input wire tft_busy,
    output reg tft_dc,
    output reg[7:0] tft_data,
    output reg tft_transmit,

    output reg busy
);

reg [$clog2(size * size) - 1 : 0]sub_pixel_counter;
reg [3:0]selection_counter;

// assign busy = selection_counter > 0 && sub_pixel_counter < size * size;

always @(posedge clk) begin
    if (rst) begin
        sub_pixel_counter <= 0;
        selection_counter <= 0;
        busy <= 0;
    end
    else begin
        if (!busy && draw) begin
            selection_counter <= selection_counter + 1;
            busy <= 1;
        end
        else if (~tft_busy) begin
            if (selection_counter < 12) begin
                case(selection_counter)
                    1:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2a};
                    2:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, x >> 8};
                    3:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, x & 8'hff};
                    4:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, (x + size - 1) >> 8};
                    5:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, (x + size - 1) & 8'hff};

                    6:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2a};
                    7:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, y >> 8};
                    8:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, y & 8'hff};
                    9:  {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, (y + size - 1) >> 8};
                    10: {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, (y + size - 1) & 8'hff};

                    11: {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b0, 8'h2c};
                endcase
            
                selection_counter <= selection_counter + 1;
            end
            else begin
                {tft_transmit, tft_dc, tft_data} <= {1'b1, 1'b1, 8'hf8};
            end
        end
        else if (tft_busy) begin
            tft_transmit <= 0;
        end
    end
end

endmodule
