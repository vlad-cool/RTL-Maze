// by Aleksandr
// this module generates a pseudo random byte
// value lies in [1, 255]
// seed 0 is auto replaces with 1

module random_byte
(
    input wire clk,
    input wire rst,
    input wire[7:0] seed,

    output reg[7:0] value
);

wire[7:0] stage1;
wire[7:0] stage2;
wire[7:0] stage3;

assign stage1 = value ^ (value << 5);
assign stage2 = stage1 ^ (stage1 >> 1);
assign stage3 = stage2 ^ (stage2 << 3);

always @(posedge clk)
begin
    if (rst) 
        value <= seed ? seed : 1;
    else
        value <= stage3;
end

endmodule
