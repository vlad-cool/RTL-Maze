// by Vladislav

module generator
(
    input wire rst,
    input wire clk,

    input wire enable,
    input wire[31:0] seed,

    output wire busy,

    output wire[159:0] h_walls,
    output wire[164:0] v_walls
);

reg [159:0] __v_walls;
reg [164:0] __h_walls;

assign h_walls = __h_walls;
assign v_walls = __v_walls;

reg [149:0] visited;

reg [3:0] current_x, current_y, prev_x, prev_y;

wire[3:0] allowed_directions;

always @(posedge clk) begin
    if (~rst) begin
        __v_walls <= {159{1'b1}};
        __h_walls <= {164{1'b1}};

        visited <= {1'b0, {149{1'b1}}};

        prev_x <= 0;
        prev_y <= 0;

        current_x <= 0;
        current_y <= 0;
    end
    else begin
        
    end
end

endmodule