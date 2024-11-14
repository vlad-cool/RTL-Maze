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
assign analyzer_rst = rst;

assign tft_rst = analyzer_rst;
assign tft_clk = analyzer_clk;
assign tft_mosi = analyzer_mosi;
assign tft_dc = analyzer_dc;
assign tft_cs = 0;

assign DEBUG_OUT3 = clk;

assign LED2 = rst;

wire [7:0]data_out_1;
wire [7:0]data_out_2;
wire dc_out_1, dc_out_2;
wire transmit_1, transmit_2;
wire spi_busy;

tft_spi spi_transmitter
(
	.global_reset(~rst),
	.clk(clk),
	
	.data(LED1 ? data_out_2 : data_out_1),
	.dc(LED1 ? dc_out_2 : dc_out_1),
	// .dc(dc_out_1),
	.transmit(LED1 ? transmit_2 : transmit_1),
	
	.tft_mosi(analyzer_mosi),
	.tft_cs(analyzer_cs),
	.tft_dc(analyzer_dc),
	.tft_clk(analyzer_clk),
	
	.busy(spi_busy)
);

tft_init tft_initializer(
	.clk(clk),
    .rst(~rst),
    .tft_busy(spi_busy),

    .tft_dc(dc_out_1),
    .tft_data(data_out_1),
    .tft_transmit(transmit_1),
    .finished(LED1)
);

player player(
    .rst(~rst),
    .clk(clk),
    .x(100),
    .y(101),
    .draw(LED1),

    .tft_busy(spi_busy),
    .tft_dc(dc_out_2),
    .tft_data(data_out_2),
    .tft_transmit(transmit_2),

    // busy
);

// assign DEBUG_OUT1 = dc_out;

endmodule
