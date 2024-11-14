//by Aleksandr
//W = src width in "pixels"
//H = src height in lines
//S = size of "pixel" in bits
//When you rotate layout: W(dst) = H(src) & H(dst) = W(src)

module swap_v_layout
#(
    parameter W = 6,
    parameter H = 6,
    parameter S = 1
)
(
    input   wire[(W*H*S - 1):0] src,
    output  wire[(W*H*S - 1):0] dst
);

genvar i;
generate
    for (i = 0; i < H; i = i + 1) 
    begin : loop
        assign dst[(W*S*(i + 1) - 1):(W*S*i)] = src[(W*S*(H - i) - 1):(W*S*(H - i - 1))];
    end
endgenerate

endmodule

module swap_h_layout
#(
    parameter W = 6,
    parameter H = 6,
    parameter S = 1
)
(
    input   wire[(W*H*S - 1):0] src,
    output  wire[(W*H*S - 1):0] dst
);

genvar i, j;
generate
    for (i = 0; i < H; i = i + 1)
    begin : row_loop
        localparam line = i * W * S;
        for (j = 0; j < W; j = j + 1)
        begin : block_loop
            assign dst[line + S * (j + 1) - 1 : line + (S * j)] = 
                   src[line + S * (W - j) - 1 : line + (S * (W - j - 1))];
        end
    end
endgenerate

endmodule

module rotate_l_layout
#(
    parameter W = 6,
    parameter H = 6,
    parameter S = 1
)
(
    input   wire[(W*H*S - 1):0] src,
    output  wire[(W*H*S - 1):0] dst
);

genvar i, j;
generate
    for (i = 0; i < H; i = i + 1)
    begin : row_loop
        for (j = 0; j < W; j = j + 1)
        begin : block_loop
            localparam ij = W - j - 1;
            assign dst[(ij * H + i + 1) * S - 1 : (ij * H + i) * S] = 
                   src[(i * W + j + 1) * S - 1 : (i * W + j) * S];
        end
    end
endgenerate

endmodule

module rotate_r_layout
#(
    parameter W = 6,
    parameter H = 6,
    parameter S = 1
)
(
    input   wire[(W*H*S - 1):0] src,
    output  wire[(W*H*S - 1):0] dst
);

genvar i, j;
generate
    for (i = 0; i < H; i = i + 1)
    begin : row_loop
        for (j = 0; j < W; j = j + 1)
        begin : block_loop
            localparam ii = H - i - 1;
            assign dst[(j * H + ii + 1) * S - 1 : (j * H + ii) * S] = 
                   src[(i * W + j + 1) * S - 1 : (i * W + j) * S];
        end
    end
endgenerate

endmodule
