// by Aleksandr

module maze_generator_test;

reg clk;
reg rst;
wire[7:0] rnd_value;
wire[159:0] h_walls;
wire[164:0] v_walls;
wire busy;

integer i, j;

random_byte rnd_gen
(
    .clk(clk),
    .rst(rst),
    .seed(17),
    .value(rnd_value)
);

maze_generator maze_gen
(
    .clk(clk),
    .rst(rst),
    .rnd(rnd_value),
    .h_expansion(15),
    .v_expansion(15),

    .h_walls(h_walls),
    .v_walls(v_walls),
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

always @(posedge clk)
begin
    if(~busy)
    begin
        $display("Generated Maze:");

        for (i = 0; i < 15; i = i + 1) 
        begin
            for (j = 0; j < 10; j = j + 1) 
            begin
                $write(".%s", h_walls[i*10 + j] ? "__" : "  ");
            end
            $display(".");
            
            for (j = 0; j < 11; j = j + 1) 
            begin
                $write("%s ", v_walls[i*11 + j] ? "| " : "  ");
            end
            $display();
        end
        
        for (j = 0; j < 10; j = j + 1) 
        begin
            $write(".%s", h_walls[150 + j] ? "__" : "  ");
        end
        $display(".");

        $stop;
    end
end
endmodule
