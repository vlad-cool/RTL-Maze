module tft_spi
(
	input wire global_reset,
	input wire clk,
	
	input wire [7:0]data,
	input wire dc,
	input wire transmit,
	
	output reg tft_mosi,
	output wire tft_cs,
	output wire tft_dc,
	output wire tft_clk,
	
	output wire busy
);

reg transmiting_flag;

reg [7:0] transmiting_byte, waiting_byte;
reg [2:0] transmit_counter;

always @(posedge clk)
begin
	if (global_reset)
	begin
		transmiting_byte <= 0;
		waiting_byte <= 0;
		transmiting_flag <= 0;
		transmit_counter <= 0;
	end
	else
	begin
		if (transmiting_flag)
		begin
			{tft_mosi, transmiting_byte[6:0]} <= transmiting_byte;
			transmit_counter <= transmit_counter - 1;
			
		end
	end
end

endmodule
