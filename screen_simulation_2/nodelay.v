// by Aleksandrs

module delay
(
    input wire clk,
    input wire set,
    input wire rst,
    input wire[7:0] ms,

    output wire free
);

assign free = 1; 

endmodule
