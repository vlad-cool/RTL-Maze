//(x, Y) - coords in pixels from left-top point
//type - type of food
//this layout supports 3 colors drawing

module food_layout
(
    input wire[3:0] x,
    input wire[3:0] y,
    input wire[1:0] type,

    output wire[1:0] value
);

wire[127:0] pixels[3:0];

assign pixels[0] = {16'b0000000000000000,
                    16'b0000000000000000,
                    16'b0000000000000000,
                    16'b0000000000000000,
                    16'b0000000000000000,
                    16'b0000000000000000,
                    16'b0000000000000000,
                    16'b0000000000000000};

assign pixels[1] = {16'b0000000000000000,
                    16'b0000000000000000,
                    16'b0000001010000000,
                    16'b0000100101100000,
                    16'b0000100101100000,
                    16'b0000001010000000,
                    16'b0000000000000000,
                    16'b0000000000000000};
                    
assign pixels[2] = {16'b1011000000000000,
                    16'b0000011000110000,
                    16'b0000000000000000,
                    16'b0000111100001100,
                    16'b0000111100000000,
                    16'b0000000000110000,
                    16'b0000000000110000,
                    16'b0001100000011011};

wire[8:0] index;
wire[2:0] sx;
assign sx = 4'd11 - x;
wire[2:0] sy;
assign sy = 4'd11 - y;
assign index = {sy, sx, 1'b0};
assign value = ((x > 3) & (x < 12) & (y > 3) & (y < 12)) ? {pixels[type][index + 1], pixels[type][index]} : 0;

endmodule
