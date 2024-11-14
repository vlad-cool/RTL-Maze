// by Vladislav

module tft_spi
(
	input wire rst,
	input wire clk,
	
	input wire [7:0]data,
	input wire dc,
	input wire transmit,
	
	output reg tft_mosi,
	output reg tft_cs,
	output reg tft_dc,
	output wire tft_clk,
	
	output reg busy
);

reg [7:0] transmiting_byte;
reg [2:0] transmit_counter;


assign tft_clk = ~clk & ~tft_cs;

always @(posedge clk)
begin
	if (rst)
	begin
		transmiting_byte <= 0;
		transmit_counter <= 0;
		tft_mosi <= 1;
		busy <= 0;
		tft_cs <= 1;
	end
	else
	begin
		if (~busy)
		begin
			tft_mosi <= 1;
			tft_cs <= 1;
		end
		if (transmit && ~busy)
		begin
			transmit_counter <= 7;
			transmiting_byte <= data;
			busy <= 1;
			tft_dc <= dc;
		end
		if (busy)
		begin
			tft_mosi <= transmiting_byte[transmit_counter];
			// tft_mosi <= transmit_counter[0];
			// {tft_mosi, transmiting_byte[6:0]} <= transmiting_byte;
			transmit_counter <= transmit_counter - 1;
			busy <= transmit_counter != 0;
			tft_cs <= 0;
		end
	end
end

endmodule
