module clock_divider
#(
	parameter DIV_FACTOR = 2
)
(
	input wire global_reset,
	input wire clk_in,
	output reg clk_out
);

reg [$clog2(DIV_FACTOR):0]counter;

always @(posedge clk_in)
begin
	counter <= global_reset ? 1 : (counter == DIV_FACTOR ? 0 : counter + 1);
	clk_out <= counter == DIV_FACTOR ? ~clk_out : clk_out;
end

endmodule
