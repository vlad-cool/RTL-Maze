// by Aleksandr
// Filling Stage: set all walls to 1

module maze_generator
(
    input wire clk,
    input wire rst,
    input wire[7:0] rnd,
    
    output reg[159:0] h_walls,
    output reg[164:0] v_walls,
    output wire busy
);

localparam H_INDEX_LIMIT = 160;
localparam V_INDEX_LIMIT = 165;

reg[7:0] filling_h_index;
reg[7:0] filling_v_index;
wire filling_stage;
assign filling_stage = (filling_v_index < V_INDEX_LIMIT);

assign busy = filling_stage;

always @(posedge clk)
begin
    if(rst)
        filling_h_index <= 0;
    else if(filling_h_index < H_INDEX_LIMIT)
        filling_h_index <= filling_h_index + 1;
end

always @(posedge clk)
begin
    if(rst)
        filling_v_index <= 0;
    if(filling_v_index < V_INDEX_LIMIT)
        filling_v_index <= filling_v_index + 1;
end

always @(posedge clk)
begin
    if(filling_h_index < H_INDEX_LIMIT)
        h_walls[filling_h_index] <= 1;
end

always @(posedge clk)
begin
    if(filling_v_index < V_INDEX_LIMIT)
        v_walls[filling_v_index] <= 1;
end

endmodule
