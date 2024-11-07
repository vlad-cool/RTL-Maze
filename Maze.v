module Maze(
	input clk,
	input rst,
	
	output wire tft_rst,
	output wire tft_clk,
	output wire tft_mosi,
	output wire tft_dc,
	output wire tft_cs
);

clock_divider#(
	.DIV_FACTOR(6)
) clock_divider (
	.global_reset(~rst),
	.clk_in(clk),
	.clk_out(tft_clk)
);

assign tft_mosi = clk;
assign tft_cs = rst;

endmodule
