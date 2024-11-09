module layout_tools_test;

wire[47:0] original = {8'b00000000,
                       8'b11000011,
                       8'b11000000,
                       8'b00011111,
                       8'b00010000,
                       8'b00010001};

wire[47:0] swap_v;
swap_v_layout#(8, 6, 1) v(.src(original), .dst(swap_v));
wire[47:0] swap_h;
swap_h_layout#(8, 6, 1) h(.src(original), .dst(swap_h));
wire[47:0] rotate_l;
rotate_l_layout#(8, 6, 1) l(.src(original), .dst(rotate_l));
wire[47:0] rotate_r;
rotate_r_layout#(8, 6, 1) r(.src(original), .dst(rotate_r));

task print_layout_horizontally(input[127:0] msg, input[47:0] layout);
    begin
        $display("%s:\n%b\n%b\n%b\n%b\n%b\n%b\n", msg,
            layout[47:40], 
            layout[39:32], 
            layout[31:24], 
            layout[23:16], 
            layout[15:8], 
            layout[7:0]
        );
    end
endtask

task print_layout_vertically(input[127:0] msg, input[47:0] layout);
    begin
        $display("%s:\n%b\n%b\n%b\n%b\n%b\n%b\n%b\n%b\n", msg,
            layout[47:42], 
            layout[41:36], 
            layout[35:30], 
            layout[29:24], 
            layout[23:18], 
            layout[17:12], 
            layout[11:6], 
            layout[5:0]
        );
    end
endtask

initial
begin
    #1;
    print_layout_horizontally("Original", original);
    print_layout_horizontally("swap_v", swap_v);
    print_layout_horizontally("swap_h", swap_h);
    print_layout_vertically("rotate_l", rotate_l);
    print_layout_vertically("rotate_r", rotate_r);
end

endmodule