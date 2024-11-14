module wall_layout_test;

genvar k;
generate
    for(k = 0; k < 16; k = k + 1)
    begin : tests
        single_state_wall_layout_test test(.left(k[3]), .top(k[2]), .right(k[1]), .bottom(k[0]));
    end
endgenerate

endmodule

module single_state_wall_layout_test
(
    input wire left,
    input wire top,
    input wire right,
    input wire bottom
);

reg[3:0] x;
reg[3:0] y;
wire value;

wall_layout wl(.x(x), .y(y), .left(left), .top(top), .right(right), .bottom(bottom), .value(value));

integer i, j;

initial
begin
    #({left, top, right, bottom} * 1000);
    $display("%s%s%s%s:", left ? "L" : "_", top ? "T" : "_", right ? "R" : "_", bottom ? "B" : "_");
    for(j = 0; j < 16; j = j + 1)
    begin
        for(i = 0; i < 16; i = i + 1)
        begin
            x = i;
            y = j;
            #1;
            $write("%b", value);
        end
        $write("\n");
    end
end

endmodule