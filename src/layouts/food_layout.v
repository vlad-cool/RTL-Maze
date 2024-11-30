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

wire[31:0] pixels[3:0];

assign pixels[0] = {8'b00000000,
                    8'b00000000,
                    8'b00000000,
                    8'b00000000};

assign pixels[1] = {8'b00000000,
                    8'b00101000,
                    8'b00101000,
                    8'b00000000};

assign pixels[2] = {8'b00101000,
                    8'b10010110,
                    8'b10010110,
                    8'b00101000};
                    
assign pixels[3] = {8'b10101010,
                    8'b10111110,
                    8'b10111110,
                    8'b10101010};

wire[4:0] index;
wire[1:0] sx;
assign sx = 4'd9 - x;
wire[1:0] sy;
assign sy = 4'd9 - y;
assign index = {sy, sx, 1'b0};
assign value = ((x > 5) & (x < 10) & (y > 5) & (y < 10)) ? {pixels[type][index + 1], pixels[type][index]} : 0;

endmodule
