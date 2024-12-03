// by Aleksandr
// This module palaces food around the scene. One item in each cell.
// Main stage: Rare food may appeare with chance of 20/255. 
// Second stage: Crux food appeares in 3 quadrants excluding the one in which the player starts.

// quadrants:
// 0  1 
// 2  3

module food_generator
(
    input wire clk,
    input wire rst,
    input wire[7:0] rnd,

    output reg[299:0] food,
    output wire busy
);

localparam RARE_FOOD_PROBABILITY = 21;

reg[7:0] index;
reg[2:0] crux_index;
wire main_stage;
wire second_stage;

assign busy = (crux_index < 4);
assign main_stage = (index < 150);
assign second_stage = (~main_stage) & busy;

wire[3:0] crux_x;
assign crux_x = ((rnd[2:0] < 5) ? rnd[2:0] : (rnd[2:0] - 5)) + (crux_index[0] ? 5 : 0); // x = (rnd % 5) + 5(if 1|3 quadrant)
wire[3:0] crux_y;
assign crux_y = ((rnd[2:0] < 7) ? rnd[2:0] : (rnd[2:0] - 7)) + (crux_index[1] ? 8 : 0); // y = (rnd % 7) + 8(if 2|3 quadrant)
wire[7:0] crux_place;
assign crux_place = crux_y * 10 + crux_x; // todo: replace * 
wire skip; // skip quadrant with player
assign skip = 0;

wire rare;
assign rare = (rnd < RARE_FOOD_PROBABILITY);

always @(posedge clk)
begin
    if(rst)
        index <= 0;
    else if(main_stage)
        index <= index + 1;
end

always @(posedge clk)
begin
    if(rst)
        crux_index <= 0;
    else if(second_stage)
        crux_index <= crux_index + 1;
end

always @(posedge clk)
begin
    if(main_stage)
    begin
        food[{index, 1'b1}] <= rare;
        food[{index, 1'b0}] <= ~rare;
    end
    else if(second_stage & (~skip))
    begin
        food[{crux_place, 1'b1}] <= 1;
        food[{crux_place, 1'b0}] <= 1;
    end
end

endmodule
