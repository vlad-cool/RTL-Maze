// by Aleksandr
// Filling Stage: set all walls to 1
// Walking Stage: generate standart 1-way maze
// Expansion Stage: remove some walls

module maze_generator
(
    input wire clk,
    input wire rst,
    input wire[7:0] rnd,
    input wire[3:0] h_expansion,
    input wire[3:0] v_expansion,
    
    output reg[159:0] h_walls,
    output reg[164:0] v_walls,
    output wire busy
);

localparam H_INDEX_LIMIT = 160;
localparam V_INDEX_LIMIT = 165;
localparam VISITED_INDEX_LIMIT = 150;
localparam DIR_UP = 0;
localparam DIR_RIGHT = 1;
localparam DIR_DOWN = 2;
localparam DIR_LEFT = 3;

assign busy = filling_stage | walking_stage | expansion_stage;

// I. Filling Stage:
reg visited[149:0];
reg[7:0] filling_h_index;
reg[7:0] filling_v_index;
reg[7:0] visited_index;
wire filling_stage;
assign filling_stage = (filling_v_index < V_INDEX_LIMIT);


// II. Walking Stage:
wire walking_stage;
assign walking_stage = (~filling_stage) & (have_valid_direction | (stack_ptr > 0));
    
reg[3:0] x, y;
wire[7:0] position;
assign position = ({3'h0, y} << 3) + ({3'h0, y} << 1) + x;

wire[1:0] valid_directions[0:3];
assign valid_directions[DIR_UP]    = ((y > 0)  & ~visited[position - 10]);
assign valid_directions[DIR_RIGHT] = ((x < 9)  & ~visited[position + 1]);
assign valid_directions[DIR_DOWN]  = ((y < 14) & ~visited[position + 10]);
assign valid_directions[DIR_LEFT]  = ((x > 0)  & ~visited[position - 1]);

wire have_valid_direction;
assign have_valid_direction = valid_directions[0] | valid_directions[1] | valid_directions[2] | valid_directions[3];

// stack
reg[3:0] stack_x[149:0];
reg[3:0] stack_y[149:0];
reg[7:0] stack_ptr;

wire[1:0] direction;
assign direction = valid_directions[rnd[1:0]] ? rnd & 2'b11 : 
                   valid_directions[(rnd + 1) & 2'b11] ? (rnd + 1) & 2'b11 : 
                   valid_directions[(rnd + 2) & 2'b11] ? (rnd + 2) & 2'b11 : (rnd + 3) & 2'b11;

// 0 <-> -1, 1 <-> 0, 2 <-> 1, 3 <-> not allowed
wire[1:0] dx[3:0];
assign dx[DIR_UP]    = 2'd1;
assign dx[DIR_RIGHT] = 2'd2;
assign dx[DIR_DOWN]  = 2'd1;
assign dx[DIR_LEFT]  = 2'd0;
wire[1:0] dy[3:0];
assign dy[DIR_UP]    = 2'd0;
assign dy[DIR_RIGHT] = 2'd1;
assign dy[DIR_DOWN]  = 2'd2;
assign dy[DIR_LEFT]  = 2'd1;

// III.Expansion Stage:
reg[3:0] expansion_h_index;
reg[3:0] expansion_v_index;
wire expansion_stage;
assign expansion_stage = (~filling_stage) & (~walking_stage) & (expansion_h_index < h_expansion) & (expansion_v_index < v_expansion);
wire[3:0] rnd_9;
assign rnd_9 = (rnd[3:0] < 9) ? rnd[3:0] : (rnd[3:0] - 9);
wire[3:0] rnd_10;
assign rnd_10 = (rnd[3:0] < 10) ? rnd[3:0] : (rnd[3:0] - 10);
wire[3:0] rnd_1_14;
assign rnd_1_14 = (rnd[3:0] < 14) ? (rnd[3:0] + 1) : (rnd[3:0] - 13);
wire[3:0] rnd_15;
assign rnd_15 = (rnd[3:0] < 15) ? rnd[3:0] : 0;

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
    else if(filling_v_index < V_INDEX_LIMIT)
        filling_v_index <= filling_v_index + 1;
end

always @(posedge clk)
begin
    if(rst)
        visited_index <= 0;
    else if(visited_index < VISITED_INDEX_LIMIT)
        visited_index <= visited_index + 1;
end

always @(posedge clk)
begin
    if(filling_h_index < H_INDEX_LIMIT) // Filling Stage
        h_walls[filling_h_index] <= 1;
    else if(walking_stage & ~direction[0] & have_valid_direction) // Walk in a vertical direction
        h_walls[position + (direction == DIR_DOWN ? 10 : 0)] <= 0;
    else if(expansion_stage & (expansion_h_index < h_expansion)) // Remove wall during expansion stage
        h_walls[({4'h0, rnd_1_14} << 3) + ({4'h0, rnd_1_14} << 1) + rnd_10] <= 0;
end

always @(posedge clk)
begin
    if(filling_v_index < V_INDEX_LIMIT) // Filling Stage
        v_walls[filling_v_index] <= 1;
    else if(walking_stage & direction[0] & have_valid_direction) // Walk in a horizontal direction
        v_walls[position + y + (direction == DIR_RIGHT)] <= 0;
    else if(expansion_stage & (expansion_v_index < v_expansion)) // Remove wall during expansion stage
        v_walls[({4'h0, rnd_15} << 3) + ({4'h0, rnd_15} << 1) + rnd_15 + rnd_9 + 1] <= 0;
end

always @(posedge clk)
begin
    if(visited_index < VISITED_INDEX_LIMIT) // Filling Stage
        visited[visited_index] <= 0;
    else if(walking_stage)
        visited[position] <= 1;
end

always @(posedge clk)
begin
    if(rst)
        stack_ptr <= 0;
    else if(walking_stage)
        stack_ptr <= have_valid_direction ? (stack_ptr + 1) : (stack_ptr - 1);
end

always @(posedge clk)
begin
    if(walking_stage & have_valid_direction)
    begin
        stack_x[stack_ptr] <= x;
        stack_y[stack_ptr] <= y;
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        x <= 0;
    end
    else if(walking_stage)
    begin
        if(have_valid_direction)
            x <= x + dx[direction] - 1;
        else
            x <= stack_x[stack_ptr - 1];
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        y <= 0;
    end
    else if(walking_stage)
    begin
        if(have_valid_direction)
            y <= y + dy[direction] - 1;
        else
            y <= stack_y[stack_ptr - 1];
    end
end

always @(posedge clk)
begin
    if(rst)
        expansion_h_index <= 0;
    else if(expansion_stage & (expansion_h_index < h_expansion))
        expansion_h_index <= expansion_h_index + 1;
end

always @(posedge clk)
begin
    if(rst)
        expansion_v_index <= 0;
    else if(expansion_stage & (expansion_v_index < v_expansion))
        expansion_v_index <= expansion_v_index + 1;
end

endmodule
