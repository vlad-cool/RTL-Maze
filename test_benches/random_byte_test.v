// by Aleksandr

module random_byte_test;

reg clk;
reg reset;
wire [7:0] random_number;

reg[7:0] counter[255:1];

random_byte rnd
(
    .clk(clk),
    .rst(reset),
    .seed(7),
    .value(random_number)
);

integer i;

initial clk = 0;
always #1 clk = ~clk;

initial begin
    for( i = 1; i < 256; i = i + 1)
        counter[i] <= 0;
    reset = 1;
    #10;
    reset = 0;
    #10000;
    for( i = 1; i < 256; i = i + 1)
        $display("%d %d", i, counter[i]);
    $stop;
end

always @(posedge clk) if(~reset) counter[random_number] <= counter[random_number] + 1;

endmodule
