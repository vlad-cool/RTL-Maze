// by Vladislav

module rotator
#(
    parameter size = 22
)
(
    input wire[$clog2(size)-1:0] x,
    input wire[$clog2(size)-1:0] y,
    input wire[1:0] direction,

    output wire[$clog2(size * size) - 1:0] index
);

assign index = direction == 0 ? (size - y - 1) * size + (size - x - 1) :
               direction == 1 ? x * size + (size - y - 1) :
               direction == 2 ? y * size + x :
               direction == 3 ? (size - x - 1) * size + y : 0;

endmodule