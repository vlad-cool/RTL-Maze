module food_generator_test;

reg clk;
reg rst;
wire[7:0] rnd_value;
wire[299:0] food;
wire busy;

integer i, j;

random_byte rnd_gen
(
    .clk(clk),
    .rst(rst),
    .seed(217),
    .value(rnd_value)
);

food_generator food_gen
(
    .clk(clk),
    .rst(rst),
    .rnd(rnd_value),

    .food(food),
    .busy(busy)
);

initial clk = 0;
always #1 clk = ~clk;

initial 
begin
    rst = 1;
    #10;
    rst = 0;
end

reg[7:0] index;
reg[1:0] value;

always @(posedge clk)
begin
    if(~busy)
    begin
        for(j = 0; j < 15; j = j + 1)
        begin
            for(i = 0; i < 10; i = i + 1)
            begin
                index = 10*j + i;
                value = 2*food[{index, 1'b1}] + food[{index, 1'b0}];
                $write("%s", (value == 1) ? "." : (value == 2) ? "*" : "#");
            end
            $display();
        end
        $stop;
    end
end

endmodule
