module Maze(
	input clk,                      // @{CLK}
	input rst,                      // @{SW0}
	
	output wire LED1,               // @{LEDR1}
	output wire LED2,               // @{LEDR2}

    input wire button_1,            // @{KEY0}
    input wire button_2,            // @{KEY1}
    input wire button_3,            // @{KEY2}
    input wire button_4,            // @{KEY3}

    output wire logic_0,            // @{GPIO_0}
    output wire logic_1,            // @{GPIO_1}
	
	output wire DEBUG_OUT1,         // @{E19}
	output wire DEBUG_OUT2,         // @{F21}
	output wire DEBUG_OUT3,         // @{F18}
	
	output wire analyzer_rst,       // @{GPIO_1}
	output wire analyzer_clk,       // @{AC21}
	output wire analyzer_mosi,      // @{Y17}
	output wire analyzer_dc,        // @{AB21}
	output wire analyzer_cs,        // @{GPIO_0}
	
	output wire tft_rst,            // @{GPIO_31}
	output wire tft_clk,            // @{GPIO_34}
	output wire tft_mosi,           // @{GPIO_33}
	output wire tft_dc,             // @{GPIO_32}
	output wire tft_cs,             // @{GPIO_30}
	output wire tft_led             // ...
);

wire [7:0]init_data_out, player_data_out, scene_data_out, spi_data_in;
wire init_dc_out, player_dc_out, scene_dc_out, spi_dc_in;
wire init_transmit_out, player_transmit_out, scene_transmit_out, spi_transmit_in;
wire init_busy, player_busy, player_busy_inner, scene_busy;

reg player_draw;

reg init_enable, player_enable, scene_enable;

wire spi_clk;
wire spi_mosi;
wire spi_dc;
wire spi_cs;

wire spi_busy;

assign spi_cs = 0;

assign analyzer_rst = rst;
assign analyzer_clk = spi_clk;
assign analyzer_mosi = spi_mosi;
assign analyzer_dc = spi_dc;
assign analyzer_cs = spi_cs;

assign tft_rst = rst;
assign tft_clk = spi_clk;
assign tft_mosi = spi_mosi;
assign tft_dc = spi_dc;
assign tft_cs = spi_cs;

tft_spi spi_transmitter
(
    .rst(~rst),
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
    .rst(~rst),
    .tft_busy(spi_busy),

    .tft_dc(init_dc_out),
    .tft_data(init_data_out),
    .tft_transmit(init_transmit_out),
    .busy(init_busy),
    .enable(init_enable)
);

wire[159:0] test_h_walls;
assign test_h_walls = {10'b1111111111,
                       10'b0111111110,
                       10'b0011111100,
                       10'b0001111000,
                       10'b0000110000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000010000,
                       10'b0000111000,
                       10'b0001111100,
                       10'b0011111110,
                       10'b0111111111,
                       10'b1111111111};


wire[164:0] test_v_walls;
assign test_v_walls = {11'b10000000001,
                       11'b11000000011,
                       11'b11100000111,
                       11'b11110001111,
                       11'b11111011111,
                       11'b11111111111,
                       11'b11111111111,
                       11'b11111111111,
                       11'b11111111111,
                       11'b11111111111,
                       11'b11111001111,
                       11'b11110000111,
                       11'b11100000011,
                       11'b11000000001,
                       11'b10000000000};


wire[299:0] test_food;
assign test_food = {20'b01101100000000000000,
                    20'b00000000000000000000,
                    20'b00000000000000000000,
                    20'b01000000000000000000,
                    20'b00000000000000000000,
                    20'b00000000000000000000,
                    20'b00000000000000000000,
                    20'b10000000000000000000,
                    20'b00000000000000000000,
                    20'b00000000000000000000,
                    20'b00010000000000000000,
                    20'b00000000000000000000,
                    20'b00000000000000000000,
                    20'b00000000000000000000,
                    20'b00100000000000111001};

scene_exhibitor scene
(
    .clk(clk),
    .rst(~rst),
    .tft_busy(spi_busy),

    .busy(scene_busy),
    .tft_dc(scene_dc_out),
    .tft_data(scene_data_out),
    .tft_transmit(scene_transmit_out),
    .enable(scene_enable),

    .h_walls(test_h_walls),
    .v_walls(test_v_walls),
    .food(test_food)
);

reg [8:0] player_pos_x, player_pos_y;

reg [1:0] direction;

reg [31:0]random_seed;

reg button_1_reg, button_2_reg, button_3_reg, button_4_reg;

reg setting_direction;

reg path_blocked;

player player
(
    .clk(clk),
    .rst(~rst),
    .tft_busy(spi_busy),

    // .busy(player_busy_inner),
    .busy(player_busy),
    .tft_dc(player_dc_out),
    .tft_data(player_data_out),
    .tft_transmit(player_transmit_out),
    .enable(player_enable),

    .x(player_pos_x[8:0] + 5),
    .y(player_pos_y[8:0] + 5),
    .draw(player_draw),

    .direction(direction)
);

// delay player_busy_delayer
// (
//     .clk(clk),
//     .rst(~rst),
//     .set(player_busy_inner),
//     .ms(100),
//     .free(player_busy)
// );

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

always @(posedge clk) begin
    button_1_reg <= ~button_1;
    button_2_reg <= ~button_2;
    button_3_reg <= ~button_3;
    button_4_reg <= ~button_4;

    if (~rst) begin
        init_enable <= 0;
        scene_enable <= 0;
        player_enable <= 0;
        player_draw <= 1;

        player_pos_x <= 0;
        player_pos_y <= 0;
        // grid_position_x <= 0;
        // grid_position_y <= 0;
        // sub_grid_postion_x <= 0;
        // sub_grid_postion_y <= 0;

        random_seed <= random_seed + 1;

        direction <= 2;
        path_blocked <= 0;

        setting_direction <= 1;
    end
    else begin
        if (~init_enable & ~scene_enable & ~player_enable) 
        begin
            init_enable <= 1;
        end
        else if (init_enable & ~init_busy) begin
            init_enable <= 0;
            scene_enable <= 1;
        end
        else if (scene_enable & ~scene_busy) begin
            scene_enable <= 0;
            player_enable <= 1;
        end
        else if (player_enable & ~player_busy) begin
            if (setting_direction & (player_pos_x[4:0] == 0) & (player_pos_y[4:0] == 0)) begin
                direction <= button_1_reg & (test_v_walls[player_pos_y[8:5] * 11 + player_pos_x[8:5] + 1] == 0) ? 0 : 
                             button_2_reg & (test_h_walls[player_pos_y[8:5] * 10 + player_pos_x[8:5] + 10] == 0) ? 1 :
                             button_3_reg & (test_v_walls[player_pos_y[8:5] * 11 + player_pos_x[8:5]] == 0) ? 2 :
                             button_4_reg & (test_h_walls[player_pos_y[8:5] * 10 + player_pos_x[8:5]] == 0) ? 3 : direction;
                    
                path_blocked <= ((button_1_reg | direction == 0) & (test_v_walls[player_pos_y[8:5] * 11 + player_pos_x[8:5] + 1] == 1))  | 
                                ((button_2_reg | direction == 1) & (test_h_walls[player_pos_y[8:5] * 10 + player_pos_x[8:5] + 10] == 1)) |
                                ((button_3_reg | direction == 2) & (test_v_walls[player_pos_y[8:5] * 11 + player_pos_x[8:5]] == 1))      |
                                ((button_4_reg | direction == 3) & (test_h_walls[player_pos_y[8:5] * 10 + player_pos_x[8:5]] == 1));
                
                setting_direction <= 0;
            end
            else
            begin
                setting_direction <= 1;
                if (~path_blocked)
                begin
                    case (direction)
                        0: begin
                            player_pos_x <= player_pos_x[8:5] < 9 ? player_pos_x + 1 : player_pos_x;
                        end
                        1: begin
                            player_pos_y <= player_pos_y[8:5] < 14 ? player_pos_y + 1 : player_pos_y;
                        end
                        2: begin
                            player_pos_x <= player_pos_x > 0 ? player_pos_x - 1 : player_pos_x;
                        end
                        3: begin
                            player_pos_y <= player_pos_y > 0 ? player_pos_y - 1 : player_pos_y;
                        end
                    endcase
                end
            end
        end
    end
end

endmodule
