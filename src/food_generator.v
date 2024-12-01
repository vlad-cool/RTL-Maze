module food_generator
(
    input wire clk,
    input wire rst,
    input wire[7:0] rnd,

    output reg[299:0] food,
    output wire busy
);

localparam RARE_FOOD_PROBABILITY = 13; // in 256

reg[7:0] index;
assign busy = (index < 150);

wire rare;
assign rare = rnd < RARE_FOOD_PROBABILITY;

always @(posedge clk)
begin
    if(rst)
        index <= 0;
    else if(busy)
        index <= index + 1;
end

always @(posedge clk)
begin
    food[{index, 1'b1}] <= rare;
    food[{index, 1'b0}] <= ~rare;
end

endmodule