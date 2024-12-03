
module pulse_delay
(
    input wire clk,
    input wire set,
    input wire rst,
    input wire[7:0] ms,

    output wire free
);

localparam[13:0] ticks_per_ms = 14'd2000;

reg[7:0] counter;
reg[13:0] low_counter;


reg prev_state;
reg current_state;

assign free = prev_state | ~current_state;

always @(posedge clk)
begin
    prev_state <= current_state;
    current_state <= counter == 0;
    if(rst)
        {counter, low_counter} <= 0;
    else if(set & (counter == 0))
        {counter, low_counter} <= {ms, ticks_per_ms};
    else if(low_counter > 0)
        low_counter <= low_counter - 1;
    else if(counter > 0)
        {counter, low_counter} <= {counter - 8'd1, ticks_per_ms};
end

endmodule
