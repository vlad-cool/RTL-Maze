module Maze(
	input clk,
	input rst,
	
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

tft_spi spi_transmitter
(
	.global_reset(~rst),
	.clk(clk),
	
	.data(data_out),
	.dc(dc_out),
	.transmit(transmit),
	
	.tft_mosi(tft_mosi),
	.tft_cs(tft_cs),
	.tft_dc(tft_dc),
	.tft_clk(tft_clk),
	
	.busy(spi_busy)
);


reg [4:0]counter;

assign transmt = counter == 2;
assign data_out = 8'b10101010;
assign dc_out = 1;

always @(posedge clk)
begin
	if (~rst)
	begin
		counter <= 0;
	end
	else
	begin
		counter <= counter + 1;
		
		// if (counter == 2 and ~spi_busy)
		// begin
		// 	
		// end
	end
end

/*
clock_divider#(
	.DIV_FACTOR(6)
) clock_divider (
	.global_reset(~rst),
	.clk_in(clk),
	.clk_out(tft_clk)
);

assign tft_mosi = clk;
assign tft_cs = rst;
*/
endmodule
