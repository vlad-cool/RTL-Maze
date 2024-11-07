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

assign DEBUG_OUT2 = tft_clk_in;
assign DEBUG_OUT3 = clk;

assign LED2 = rst;

wire [7:0]data_out;
wire dc_out;
wire transmit;
wire spi_busy;

wire tft_clk_in;

clock_divider#(
	.DIV_FACTOR(5)
) clock_divider (
	.global_reset(~rst),
	.clk_in(clk),
	.clk_out(tft_clk_in)
);

tft_spi spi_transmitter
(
	.global_reset(~rst),
	.clk(clk),
	
	.data(data_out),
	.dc(dc_out),
	.transmit(transmit),
	
	.tft_mosi(analyzer_mosi),
	.tft_cs(analyzer_cs),
	.tft_dc(analyzer_dc),
	.tft_clk(analyzer_clk),
	
	.busy(spi_busy)
);

tft_init tft_initializer(
	 .clk(clk),
    .global_reset(~rst),
    .tft_busy(spi_busy),

    .tft_dc(dc_out),
    .tft_data(data_out),
    .tft_transmit(transmit),
    .finished(LED1)
);

assign DEBUG_OUT1 = dc_out;

endmodule
