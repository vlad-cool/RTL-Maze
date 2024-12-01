// by Aleksandr
// this module generates a pseudo random byte

module random_byte
(
    input wire clk,
    input wire rst,
    input wire[7:0] seed,

    output reg[7:0] value
);

always @(posedge clk)
begin
    if (rst) 
        value <= seed;
    else
        value <= {value[6:0] ^ 7'b0101000, value[7] ^ value[5] ^ value[4] ^ value[3]};
end

endmodule
