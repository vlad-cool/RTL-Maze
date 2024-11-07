module Maze(
	input clk,
	input rst,
	
	output wire LED1,
	output wire LED2,
	
	output wire DEBUG_OUT1,
	
	output wire tft_rst,
	output wire tft_clk,
	output wire tft_mosi,
	output wire tft_dc,
	output wire tft_cs
);

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
	.clk(tft_clk_in),
	
	.data(data_out),
	.dc(dc_out),
	.transmit(transmit),
	
	.tft_mosi(tft_mosi),
	.tft_cs(tft_cs),
	.tft_dc(tft_dc),
	.tft_clk(tft_clk),
	
	.busy(spi_busy)
);

tft_init tft_initializer(
	 .clk(tft_clk_in),
    .rst(~rst),
    .tft_busy(spi_busy),

    .tft_dc(dc_out),
    .tft_data(data_out),
    .tft_transmit(transmit),
    .finished(LED1)
);

assign DEBUG_OUT1 = dc_out;

endmodule
