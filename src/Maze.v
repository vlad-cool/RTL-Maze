module Maze
(
	input clk,                      // @{CLK}
	input true_rst,                 // @{SW0}

    input wire button_1,            // @{KEY2}
    input wire button_2,            // @{KEY1}
    input wire button_3,            // @{KEY3}
    input wire button_4,            // @{KEY0}

	output wire tft_clk,            // @{GPIO_26}
	output wire tft_mosi,           // @{GPIO_28}
	output wire tft_dc,             // @{GPIO_30}
	output wire tft_rst,            // @{GPIO_32}
	output wire tft_cs,             // @{GPIO_34}

    output wire[6:0] hex_disp_1,    // @{HEX0}
    output wire[6:0] hex_disp_2,    // @{HEX1}
    output wire[6:0] hex_disp_3,    // @{HEX2}
    output wire[6:0] hex_disp_4     // @{HEX3}
);

// `define PLAYER_SPEED_FACTOR 32

localparam FOOD_0_COST = 1;
localparam FOOD_1_COST = 4;
localparam FOOD_2_COST = 16;
localparam FOOD_3_COST = 64;

wire[7:0] init_data_out, player_data_out, scene_data_out, spi_data_in;
wire init_dc_out, player_dc_out, scene_dc_out, spi_dc_in;
wire init_transmit_out, player_transmit_out, scene_transmit_out, spi_transmit_in;
wire init_busy, player_busy, scene_busy;

wire[1:0] direction_wire;

reg[$clog2(`PLAYER_SPEED_FACTOR)-1:0] player_counter;

reg init_enable, player_enable, scene_enable;

reg[149:0] visited_cells;
reg[$clog2(`FREQUENCY)-1:0] sub_seconds_counter;
reg[15:0] seconds_counter;
reg[15:0] score;
reg[15:0] final_score;

reg soft_rst;

reg[7:0] random_seed;

wire spi_clk;
wire spi_mosi;
wire spi_dc;
wire spi_cs;

wire spi_busy;

wire rst;

wire first_cell_step;

assign first_cell_step = setting_direction & (player_pos_x[4:0] == 0) & (player_pos_y[4:0] == 0);

assign spi_cs = 0;

assign tft_rst = ~rst;
assign tft_clk = spi_clk;
assign tft_mosi = spi_mosi;
assign tft_dc = spi_dc;
assign tft_cs = spi_cs;

assign rst = ~(true_rst & soft_rst);

wire direction_1_free, direction_2_free, direction_3_free, direction_4_free;

assign direction_1_free = v_walls[player_pos_y[8:5] * 11 + player_pos_x[8:5] + 1] == 0;
assign direction_2_free = h_walls[player_pos_y[8:5] * 10 + player_pos_x[8:5] + 10] == 0;
assign direction_3_free = v_walls[player_pos_y[8:5] * 11 + player_pos_x[8:5]] == 0;
assign direction_4_free = h_walls[player_pos_y[8:5] * 10 + player_pos_x[8:5]] == 0;

assign direction_wire = button_1_reg & direction_1_free ? 0 : 
                        button_2_reg & direction_2_free ? 1 :
                        button_3_reg & direction_3_free ? 2 :
                        button_4_reg & direction_4_free ? 3 : direction;

tft_spi spi_transmitter
(
    .rst(rst),
	.clk(clk),
	
	.data(spi_data_in),
	.dc(spi_dc_in),
	.transmit(spi_transmit_in),
	
	.tft_mosi(spi_mosi),
	// .tft_cs(spi_cs),
	.tft_dc(spi_dc),
	.tft_clk(spi_clk),
	
	.busy(spi_busy)
);

tft_init tft_initializer
(
	.clk(clk),
    .rst(rst),
    .tft_busy(spi_busy),

    .tft_dc(init_dc_out),
    .tft_data(init_data_out),
    .tft_transmit(init_transmit_out),
    .busy(init_busy),
    .enable(init_enable)
);

wire[7:0] rnd_value;
random_byte rnd
(
    .clk(clk),
    .rst(rst),
    .seed(random_seed),

    .value(rnd_value)
);

wire[299:0] food;
wire food_gen_busy;

food_generator food_gen
(
    .clk(clk),
    .rst(rst),
    .rnd(rnd_value),
    .player_x(player_pos_x[8:5]),
    .player_y(player_pos_y[8:5]),

    .food(food),
    .busy(food_gen_busy)
);

wire[159:0] h_walls;
wire[164:0] v_walls;
wire maze_gen_busy;

maze_generator maze_gen
(
	.clk(clk),
    .rst(rst),
    .rnd(rnd_value),
    .h_expansion(15),
    .v_expansion(15),

    .h_walls(h_walls),
    .v_walls(v_walls),
    .busy(maze_gen_busy)
);

scene_exhibitor scene
(
    .clk(clk),
    .rst(rst),
    .tft_busy(spi_busy),

    .busy(scene_busy),
    .tft_dc(scene_dc_out),
    .tft_data(scene_data_out),
    .tft_transmit(scene_transmit_out),
    .enable(scene_enable),

    .h_walls(h_walls),
    .v_walls(v_walls),
    .food(food)
);

reg[8:0] player_pos_x, player_pos_y;
reg[1:0] direction;
reg button_1_reg, button_2_reg, button_3_reg, button_4_reg;
reg setting_direction;
reg path_free;

player player
(
    .clk(clk),
    .rst(rst),
    .tft_busy(spi_busy),

    .busy(player_busy),
    .tft_dc(player_dc_out),
    .tft_data(player_data_out),
    .tft_transmit(player_transmit_out),
    .enable(player_enable),

    .x(player_pos_x[8:0] + 5),
    .y(player_pos_y[8:0] + 5),

    .direction(direction)
);

segment_display display_1
(
    .number(final_score[3:0]),
    .disp(hex_disp_1)
);

segment_display display_2
(
    .number(final_score[7:4]),
    .disp(hex_disp_2)
);

segment_display display_3
(
    .number(final_score[11:8]),
    .disp(hex_disp_3)
);

segment_display display_4
(
    .number(final_score[15:12]),
    .disp(hex_disp_4)
);

assign spi_data_in = 
    init_enable ? init_data_out :
    scene_enable ? scene_data_out :
    player_enable ? player_data_out : 
    0;

assign spi_dc_in = 
    init_enable ? init_dc_out :
    scene_enable ? scene_dc_out :
    player_enable ? player_dc_out : 
    0;

assign spi_transmit_in = 
    init_enable ? init_transmit_out :
    scene_enable ? scene_transmit_out :
    player_enable ? player_transmit_out :
    0;

always @(posedge clk)
begin
    button_1_reg <= ~button_1;
    button_2_reg <= ~button_2;
    button_3_reg <= ~button_3;
    button_4_reg <= ~button_4;
end

always @(posedge clk)
begin
    if (rst)
    begin
        soft_rst <= 1;
    end
    else if (visited_cells == {150 {1'b1}})
    begin
        soft_rst <= 0;
    end
end

always @(posedge clk)
begin
    if (rst)
    begin
        final_score <= 0;
    end
    else
    begin
        final_score <= seconds_counter > score ? 0 : score - seconds_counter;
    end
end

always @(posedge clk)
begin
    if (rst)
    begin
        init_enable <= 0;
        scene_enable <= 0;
        player_enable <= 0;
    end
    else
    begin
        if (~food_gen_busy & ~maze_gen_busy & ~init_enable & ~scene_enable & ~player_enable) 
        begin
            init_enable <= 1;
        end
        if (init_enable & ~init_busy)
        begin
            init_enable <= 0;
            scene_enable <= 1;
        end
        if (scene_enable & ~scene_busy)
        begin
            scene_enable <= 0;
            player_enable <= 1;
        end
    end
end

always @(posedge clk)
begin
    if (rst)
    begin
        setting_direction <= 1;
    end
    else
    begin
        if (player_enable & ~player_busy)
        begin
            if (first_cell_step)
            begin
                setting_direction <= 0;
            end
            else if (player_counter == 0)
            begin
                setting_direction <= 1;
            end
        end
    end
end

always @(posedge clk)
begin
    if (rst)
    begin
        direction <= 2;
    end
    else if (first_cell_step)
    begin
        direction <= direction_wire;
    end
end

always @(posedge clk)
begin
    if (rst)
    begin
        path_free <= 0;
    end
    else if (first_cell_step) 
    begin
        path_free <= ((direction_wire == 0) & (direction_1_free)) |
                     ((direction_wire == 1) & (direction_2_free)) |
                     ((direction_wire == 2) & (direction_3_free)) |
                     ((direction_wire == 3) & (direction_4_free));
    end
end

always @(posedge clk)
begin
    if (rst)
    begin
        visited_cells <= 0;
        score <= 150;
    end
    else
    begin
        if (player_enable & ~player_busy)
        begin              
            if (first_cell_step & visited_cells[player_pos_x[8:5] * 15 + player_pos_y[8:5]] == 0)
            begin
                case (food[(player_pos_x[8:5] + player_pos_y[8:5] * 10) << 1])
                    0: score <= score + FOOD_0_COST;
                    1: score <= score + FOOD_1_COST;
                    2: score <= score + FOOD_2_COST;
                    3: score <= score + FOOD_3_COST;
                endcase
                visited_cells[player_pos_x[8:5] * 15 + player_pos_y[8:5]] <= 1;
            end
        end
    end
end

always @(posedge clk)
begin
    if (rst)
    begin
        player_pos_x <= 0;
        player_pos_y <= 0;
        player_counter <= 0;
    end
    else
    begin
        if (player_enable & ~player_busy)
        begin
            if (~first_cell_step)
            begin
                player_counter <= player_counter == 0 ? `PLAYER_SPEED_FACTOR - 1 : player_counter - 1;
                if (player_counter == 0)
                begin
                    if (path_free)
                    begin
                        case (direction)
                            0: player_pos_x <= player_pos_x[8:5] < 9 ? player_pos_x + 1 : player_pos_x;
                            1: player_pos_y <= player_pos_y[8:5] < 14 ? player_pos_y + 1 : player_pos_y;
                            2: player_pos_x <= player_pos_x > 0 ? player_pos_x - 1 : player_pos_x;
                            3: player_pos_y <= player_pos_y > 0 ? player_pos_y - 1 : player_pos_y;
                        endcase
                    end
                end
            end
        end
    end
end

always @(posedge clk)
begin
    if (rst)
    begin
        sub_seconds_counter <= `FREQUENCY - 1;
        seconds_counter <= 0;
    end
    begin
        sub_seconds_counter <= sub_seconds_counter == 0 ? `FREQUENCY - 1 : sub_seconds_counter - 1;
        seconds_counter <= sub_seconds_counter == 0 ? seconds_counter + 1 : seconds_counter;
    end
end

always @(posedge clk)
begin
    if (rst)
    begin
        random_seed <= random_seed + 1;
    end
end

endmodule
