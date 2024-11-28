// by Vladislav

module generator
(
    input wire rst,
    input wire clk,

    input wire enable,
    input wire[31:0] seed,

    output wire busy;

    output wire[159:0] h_walls,
    output wire[164:0] v_walls
)

reg [134:0] v_walls;
reg [139:0] h_walls;

reg [149:0] visited;

reg [3:0] current_x, current_y, prev_x, prev_y;

wire[3:0] allowed_directions;

always @(posedge clk) begin
    if (~rst) begin
        v_walls <= {135{'b1}};
        h_walls <= {139{'b1}};

        visited <= {0, 149{'b1}};

        prev_x <= 0;
        prev_y <= 0;

        current_x <= 0;
        current_y <= 0;
    end
    else begin
        
    end
end

endmodule