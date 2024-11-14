// by Aleksandr
// 16x16 walls layout
// (x, Y) - coords in pixels from left-top point
// left, top, right, bottom is flags of other walls

module wall_layout
(
    input wire[3:0] x,
    input wire[3:0] y,
    input wire left,
    input wire top,
    input wire right,
    input wire bottom,

    output wire value
);

localparam EMPTY    = 4'b0000;
localparam SINGLE   = 4'b0001;
localparam ANGLED   = 4'b0011;
localparam STRAIGHT = 4'b0101;
localparam TRIPLE   = 4'b0111;
localparam FULL     = 4'b1111;

wire[5:0] sx;
wire[5:0] sy;
wire v_line;
wire h_line;

wire[35:0] core[15:0];
assign core[EMPTY] =   {6'b000000, 
                        6'b000000,
                        6'b000000,
                        6'b000000,
                        6'b000000,
                        6'b000000};

assign core[SINGLE] =  {6'b000000,
                        6'b001100,
                        6'b010010,
                        6'b010010,
                        6'b010010,
                        6'b010010};
swap_v_layout   T(.src(core[SINGLE]), .dst(core[4'b0100]));
rotate_l_layout R(.src(core[SINGLE]), .dst(core[4'b0010]));
rotate_r_layout L(.src(core[SINGLE]), .dst(core[4'b1000]));

assign core[ANGLED] =  {6'b000000, 
                        6'b000001,
                        6'b000110,
                        6'b001000,
                        6'b001000,
                        6'b010001};
swap_h_layout   LB(.src(core[ANGLED]), .dst(core[4'b1001]));
swap_v_layout   TR(.src(core[ANGLED]), .dst(core[4'b0110]));
swap_h_layout   LT(.src(core[4'b0110]), .dst(core[4'b1100]));

assign core[STRAIGHT]= {6'b010010,
                        6'b010010,
                        6'b010010,
                        6'b010010,
                        6'b010010,
                        6'b010010};
rotate_l_layout   LR(.src(core[STRAIGHT]), .dst(core[4'b1010]));

assign core[TRIPLE] =  {6'b010001,
                        6'b010000,
                        6'b010000,
                        6'b010000,
                        6'b010000,
                        6'b010001};
swap_h_layout     TRB(.src(core[TRIPLE]), .dst(core[4'b1101]));
rotate_l_layout   LTR(.src(core[TRIPLE]), .dst(core[4'b1110]));
rotate_r_layout   LRB(.src(core[TRIPLE]), .dst(core[4'b1011]));

assign core[FULL] =    {6'b100001, 
                        6'b000000,
                        6'b001100,
                        6'b001100,
                        6'b000000,
                        6'b100001};

assign sx = 10 - x;
assign sy = 10 - y; 
assign v_line = (top & (y < 5)) | (bottom & (y > 10));
assign h_line = (left & (x < 5)) | (right & (x > 10));
assign value =  ((x > 4) & (x < 11) & (y > 4) & (y < 11)) ? 
                core[{left, top, right, bottom}][(sy << 2) + (sy << 1) + sx] :
                ((h_line & ((y == 6) | (y == 9))) | (v_line & ((x == 6) | (x == 9))));

endmodule
