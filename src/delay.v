// by Aleksandr
// Create delay for [0 to 255] ms.

module delay
(
    input wire clk,
    input wire set,
    input wire rst,
    input wire[7:0] ms,

    output wire free
);

localparam low_counter_size = $clog2(`FREQUENCY / 1000) - 1;

localparam[low_counter_size:0] ticks_per_ms = `FREQUENCY / 1000;

reg[7:0] counter;
reg[low_counter_size:0] low_counter;

assign free = (counter == 0); 

always @(posedge clk)
begin
    if(rst)
        {counter, low_counter} <= 0;
    else if(set)
        {counter, low_counter} <= {ms, ticks_per_ms};
    else if(low_counter > 0)
        low_counter <= low_counter - 1;
    else if(counter > 0)
        {counter, low_counter} <= {counter - 8'd1, ticks_per_ms};
end

endmodule
