module Maze(
	input clk,                      // @{CLK}
	input rst,                      // @{KEY0}
	
	output wire LED1,               // @{LEDR1}
	output wire LED2,               // @{LEDR2}

    input wire button_1,            // @{KEY1}
    input wire button_2,            // @{KEY2}

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

assign logic_0 = 0;
assign logic_1 = 1;

assign tft_led = 0;

wire [7:0]init_data_out, player_data_out, scene_data_out, spi_data_in;
wire init_dc_out, player_dc_out, scene_dc_out, spi_dc_in;
wire init_transmit_out, player_transmit_out, scene_transmit_out, spi_transmit_in;
wire init_busy, player_busy, scene_busy;

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
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0011111110,
                       10'b0111111111,
                       10'b1111111111};


wire[164:0] test_v_walls;
assign test_v_walls = {11'b10000000001,
                       11'b11000000011,
                       11'b11000000011,
                       11'b11000000011,
                       11'b11000000011,
                       11'b11000000011,
                       11'b11000000011,
                       11'b11000000011,
                       11'b11000000011,
                       11'b11000000011,
                       11'b11000000011,
                       11'b11000000011,
                       11'b11000000011,
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

wire player_debug;

reg [31:0]random_seed;

reg button_1_reg, button_2_reg;

player player
(
    .clk(clk),
    .rst(~rst),
    .tft_busy(spi_busy),

    .busy(player_busy),
    .tft_dc(player_dc_out),
    .tft_data(player_data_out),
    .tft_transmit(player_transmit_out),
    .enable(player_enable),

    .debug(player_debug),

    .x(player_pos_x[8:0] + 5),
    .y(player_pos_y[8:0] + 5),
    .draw(player_draw)
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

always @(posedge clk) begin
    button_1_reg <= button_1;
    button_2_reg <= button_2;

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

        direction <= 0;
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
            if (player_pos_x[4:0] == 0 && player_pos_y[4:0] == 0) begin
                direction <= {button_1_reg, button_2_reg};
                case ({button_1, button_2})
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
            else
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

            // if (button_1)
            //     if (button_2)
            //         player_pos_y <= player_pos_y + 2;
            //     else
            //         player_pos_y <= player_pos_y - 2;
            // else
            //     if (button_2)
            //         player_pos_x <= player_pos_x + 2;
            //     else
            //         player_pos_x <= player_pos_x - 2;
        end
    end
end

// assign DEBUG_OUT1 = dc_out;

assign DEBUG_OUT1 = player_debug;
assign DEBUG_OUT2 = scene_enable;
assign DEBUG_OUT3 = player_enable;

assign LED2 = scene_busy;

endmodule
