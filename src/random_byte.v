// by Aleksandr
// this module generates a pseudo random byte
// value lies in range [0, 255]

module random_byte
(
    input wire clk,
    input wire rst,
    input wire[7:0] seed,

    output reg[7:0] value
);

wire feedback;
assign feedback = ((value[7] ^ value[5] ^ value[4] ^ value[3]) | (value == 8'b0)) & (value != 8'd128);

always @(posedge clk)
begin
    if (rst)
        value <= seed;
    else
        value <= {value[6:0], feedback};
end

endmodule
