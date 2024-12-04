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

assign busy = filling_stage | have_valid_direction | (stack_ptr > 0);

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

reg visited[149:0];    
reg[3:0] x, y;
    
// stack
reg[3:0] stack_x [149:0];
reg[3:0] stack_y [149:0];
reg[7:0] stack_ptr;

// Directions: 0 = North, 1 = East, 2 = South, 3 = West
reg[1:0] direction;
wire[1:0] valid_directions [0:3];
reg[1:0] random_direction;

assign valid_directions[0] = ((y > 0) & ~visited[(y-1)*10 + x]); // North
assign valid_directions[1] = ((x < 9) & ~visited[y*10 + x +1]); // East
assign valid_directions[2] = ((y < 14) & ~visited[(y+1)*10 + x]); // South
assign valid_directions[3] = ((x > 0) & ~visited[10*y + x - 1]); // West

wire have_valid_direction = valid_directions[0] | valid_directions[1] | valid_directions[2] | valid_directions[3];

integer i, j;

wire[1:0] next;
assign next = valid_directions[rnd % 4] ? rnd % 4 : 
              valid_directions[(rnd + 1) % 4] ? (rnd + 1) % 4 : 
              valid_directions[(rnd + 2) % 4] ? (rnd + 2) % 4 : (rnd + 3) % 4;

always @(posedge clk) 
begin
    $monitor("time=%0d: signal1=%d, signal2=%d", $time, have_valid_direction, stack_ptr);
    if (rst) 
    begin
        x <= 0;
        y <= 0;
        stack_ptr <= 0;
        for (i = 0; i < 10; i = i + 1) 
        begin
            for (j = 0; j < 15; j = j + 1) 
            begin
                visited[j*10+i] <= 0;
            end
        end
    end 
    else if(busy & ~filling_stage)
    begin
        if (have_valid_direction) 
        begin
            case (next)
                0: begin
                    if (valid_directions[0]) 
                    begin
                        h_walls[y*10 + x] <= 0;
                        y <= y - 1;
                    end
                end
                1: begin // East
                    if (valid_directions[1]) 
                    begin
                        v_walls[y*11 + x + 1] <= 0;
                        x <= x + 1;
                    end
                end
                2: begin // South
                    if (valid_directions[2]) begin
                        h_walls[(y+1)*10 + x] <= 0;
                        y <= y + 1;
                    end
                end
                3: begin // West
                    if (valid_directions[3]) 
                    begin
                        v_walls[y*11 + x] <= 0;
                        x <= x - 1;
                    end
                end
            endcase
            visited[y*10+x] <= 1;
            stack_x[stack_ptr] <= x;
            stack_y[stack_ptr] <= y;
            stack_ptr <= stack_ptr + 1;
        end 
        else 
        begin
            if (stack_ptr > 0) 
            begin
                visited[10*y+x] <= 1;
                stack_ptr <= stack_ptr - 1;
                x <= stack_x[stack_ptr - 1];
                y <= stack_y[stack_ptr - 1];
            end
        end
    end
end

endmodule
