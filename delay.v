module delay
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
        {counter, low_counter} <= {counter - 1, ticks_per_ms};
end

endmodule