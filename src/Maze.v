module Maze(
	input clk,
	input rst,
	
	output wire LED1,
	output wire LED2,
	
	output wire DEBUG_OUT1,
	output wire DEBUG_OUT2,
	output wire DEBUG_OUT3,
	
	output wire analyzer_rst,
	output wire analyzer_clk,
	output wire analyzer_mosi,
	output wire analyzer_dc,
	output wire analyzer_cs,
	
	output wire tft_rst,
	output wire tft_clk,
	output wire tft_mosi,
	output wire tft_dc,
	output wire tft_cs,
	output wire tft_led
);

assign tft_led = 0;

wire [7:0]init_data_out, player_data_out, scene_data_out, spi_data_in;
wire init_dc_out, player_dc_out, scene_dc_out, spi_dc_in;
wire init_transmit_out, player_transmit_out, scene_transmit_out, spi_transmit_in;
wire init_busy, player_busy, scene_busy;

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

tft_init tft_initializer(
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
assign test_h_walls = {10'b1000000010,
                       10'b0111011100,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0011110000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0000000000,
                       10'b0001111110};


wire[164:0] test_v_walls;
assign test_v_walls = {11'b10000000100,
                       11'b01110111000,
                       11'b00000000000,
                       11'b00000000000,
                       11'b00000000000,
                       11'b00111100000,
                       11'b00000000000,
                       11'b00000001000,
                       11'b00000001000,
                       11'b00000001000,
                       11'b00000000000,
                       11'b00000001000,
                       11'b00000001000,
                       11'b00000001000,
                       11'b00000001000};

scene_exhibitor scene(
    .clk(clk),
    .rst(~rst),
    .tft_busy(spi_busy),

    .busy(scene_busy),
    // .tft_dc(scene_dc_out),
    .tft_data(scene_data_out),
    .tft_transmit(scene_transmit_out),
    .enable(scene_enable),

    .h_walls(test_h_walls),
    .v_walls(test_v_walls)
);

assign scene_dc_out = 1; // TODO FIX

player player(
    .clk(clk),
    .rst(~rst),
    .tft_busy(spi_busy),

    .busy(player_busy),
    .tft_data(player_data_out),
    .tft_transmit(player_transmit_out),
    .enable(player_enable),

    .x(100),
    .y(101)
);

assign spi_data_in = 
    init_enable ? init_data_out :
    scene_enable ? scene_data_out :
    player_enable ? player_data_out : 
    0;

assign spi_dc_in = 
    init_enable ? init_dc_out :
    scene_enable ? 1 :
    player_enable ? player_dc_out : 
    0;

assign spi_transmit_in = 
    init_enable ? init_transmit_out :
    scene_enable ? scene_transmit_out :
    player_enable ? player_transmit_out :
    0;

always @(posedge clk) begin
    if (~rst) begin
        init_enable <= 0;
        scene_enable <= 0;
        player_enable <= 0;
    end
    else begin
        if (~init_enable & ~scene_enable & ~player_enable) begin
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
    end
end

// assign DEBUG_OUT1 = dc_out;

assign DEBUG_OUT1 = scene_enable;
assign DEBUG_OUT2 = scene_busy;
assign DEBUG_OUT3 = player_enable;

assign LED2 = scene_busy;

endmodule
