module segment_display
(
    input wire[31:0] number,

    output wire[6:0] disp
);

assign disp =
        number ==  0 ? 7'b1000000 :
        number ==  1 ? 7'b1111001 :
        number ==  2 ? 7'b0100100 :
        number ==  3 ? 7'b0110000 :
        number ==  4 ? 7'b0011001 :
        number ==  5 ? 7'b0010010 :
        number ==  6 ? 7'b0000010 :
        number ==  7 ? 7'b1111000 :
        number ==  8 ? 7'b0000000 :
        number ==  9 ? 7'b0010000 :
        number == 10 ? 7'b0001000 :
        number == 11 ? 7'b0000011 :
        number == 12 ? 7'b1000110 :
        number == 13 ? 7'b0100001 :
        number == 14 ? 7'b0000110 :
        number == 15 ? 7'b0001110 : 7'b1000000;

endmodule