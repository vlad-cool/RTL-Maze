// by Aleksandr
// top module for screen simulation

module top;

reg clk;
reg rst;

Maze maze(.clk(clk), .rst(rst));

initial begin
    rst = 0;
    clk = 0;
    #5;
    rst = 1;
end

always #1 clk <= ~clk;

endmodule