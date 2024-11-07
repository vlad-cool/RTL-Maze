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


reg [4:0]counter;

reg [7:0]transmit_data;

assign transmit = 1;
// assign data_out = 8'b10000001;
assign data_out = transmit_data;
assign dc_out = 1;

assign DEBUG_OUT1 = transmit;

always @(posedge tft_clk_in)
begin
	if (~rst)
	begin
		counter <= 0;
		transmit_data <= 0;
	end
	else
	begin
		counter <= counter + 1;
		
		transmit_data <= counter == 0 ? transmit_data + 1 : transmit_data;
		
		// if (counter == 2 and ~spi_busy)
		// begin
		// 	
		// end
	end
end

/*


assign tft_mosi = clk;
assign tft_cs = rst;
*/
endmodule
