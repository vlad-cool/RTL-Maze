module tft_init
(
    input wire clk,
    input wire rst,
    input wire tft_busy,

    output reg tft_dc,
    output reg[7:0] tft_data,
    output reg tft_transmit,
    output reg finished
);

localparam[1:0] COMM = 2'b00;
localparam[1:0] DATA = 2'b01;
localparam[1:0] WAIT = 2'b10;

wire[9:0] init_sequence[127:0];
assign init_sequence[0]  = {WAIT, 8'hff};
assign init_sequence[0+1]  = {COMM, 8'hc0};
assign init_sequence[1+1]  = {DATA, 8'h17};
assign init_sequence[1+2]  = {DATA, 8'h15};
assign init_sequence[1+3]  = {COMM, 8'hc1};
assign init_sequence[1+4]  = {DATA, 8'h41};
assign init_sequence[1+5]  = {COMM, 8'hc5};
assign init_sequence[1+6]  = {DATA, 8'h00};
assign init_sequence[1+7]  = {DATA, 8'h12};
assign init_sequence[1+8]  = {DATA, 8'h80};
assign init_sequence[1+9]  = {COMM, 8'h36};
assign init_sequence[1+10] = {DATA, 8'h48};
assign init_sequence[1+11] = {COMM, 8'h3a};
assign init_sequence[1+12] = {DATA, 8'h66};
assign init_sequence[1+13] = {COMM, 8'hb0};
assign init_sequence[1+14] = {DATA, 8'h80};
assign init_sequence[1+15] = {COMM, 8'hb1};
assign init_sequence[1+16] = {DATA, 8'ha0};
assign init_sequence[1+17] = {COMM, 8'hb6};
assign init_sequence[1+18] = {DATA, 8'h02};
assign init_sequence[1+19] = {DATA, 8'h02};
assign init_sequence[1+20] = {COMM, 8'he9};
assign init_sequence[1+21] = {DATA, 8'h00};
assign init_sequence[1+22] = {COMM, 8'hf7};
assign init_sequence[1+23] = {DATA, 8'ha9};
assign init_sequence[1+24] = {DATA, 8'h51};
assign init_sequence[1+25] = {DATA, 8'h2c};
assign init_sequence[1+26] = {DATA, 8'h82};
assign init_sequence[1+27] = {COMM, 8'h11};
assign init_sequence[1+28] = {WAIT, 8'hff};
assign init_sequence[1+29] = {COMM, 8'h29};
assign init_sequence[1+30] = {COMM, 8'h21};
assign init_sequence[1+31] = {COMM, 8'h34};

assign init_sequence[1+32] = {WAIT, 8'hff};

assign init_sequence[1+33] = {COMM, 8'h2a};
assign init_sequence[1+34] = {DATA, 8'h00};
assign init_sequence[1+35] = {DATA, 8'h10};
assign init_sequence[1+36] = {DATA, 8'h00};
assign init_sequence[1+37] = {DATA, 8'h10};
assign init_sequence[1+38] = {COMM, 8'h2b};
assign init_sequence[1+39] = {DATA, 8'h00};
assign init_sequence[1+40] = {DATA, 8'h10};
assign init_sequence[1+41] = {DATA, 8'h00};
assign init_sequence[1+42] = {DATA, 8'h10};
assign init_sequence[1+43] = {COMM, 8'h2c};

assign init_sequence[1+44] = {DATA, 8'hff};
assign init_sequence[1+45] = {DATA, 8'hff};
assign init_sequence[1+46] = {DATA, 8'hff};
assign init_sequence[1+47] = {DATA, 8'hff};
assign init_sequence[1+48] = {DATA, 8'hff};
assign init_sequence[1+49] = {DATA, 8'hff};
assign init_sequence[1+50] = {DATA, 8'hff};
assign init_sequence[1+51] = {DATA, 8'hff};
assign init_sequence[1+52] = {DATA, 8'hff};
assign init_sequence[1+53] = {DATA, 8'hff};
assign init_sequence[1+54] = {DATA, 8'hff};
assign init_sequence[1+55] = {DATA, 8'hff};
assign init_sequence[1+56] = {DATA, 8'hff};
assign init_sequence[1+57] = {DATA, 8'hff};
assign init_sequence[1+58] = {DATA, 8'hff};
assign init_sequence[1+59] = {DATA, 8'hff};
assign init_sequence[1+60] = {DATA, 8'hff};
assign init_sequence[1+61] = {DATA, 8'hff};
assign init_sequence[1+62] = {DATA, 8'hff};
assign init_sequence[1+63] = {DATA, 8'hff};
assign init_sequence[1+64] = {DATA, 8'hff};
assign init_sequence[1+65] = {DATA, 8'hff};
assign init_sequence[1+66] = {DATA, 8'hff};
assign init_sequence[1+67] = {DATA, 8'hff};
assign init_sequence[1+68] = {DATA, 8'hff};
assign init_sequence[1+69] = {DATA, 8'hff};
assign init_sequence[1+70] = {DATA, 8'hff};
assign init_sequence[1+71] = {DATA, 8'hff};
assign init_sequence[1+72] = {DATA, 8'hff};
assign init_sequence[1+73] = {DATA, 8'hff};
assign init_sequence[1+74] = {DATA, 8'hff};
assign init_sequence[1+75] = {DATA, 8'hff};
assign init_sequence[1+76] = {DATA, 8'hff};
assign init_sequence[1+77] = {DATA, 8'hff};
assign init_sequence[1+78] = {DATA, 8'hff};
assign init_sequence[1+79] = {DATA, 8'hff};

reg prev_rst;
reg[10:0] index;
reg set_wait_delay;
reg[7:0] wait_delay_value;
wire not_wait;

delay wait_delay
(
    .clk(clk),
    .set(set_wait_delay),
    .rst(rst),
    .ms(wait_delay_value),
    .free(not_wait)
);

always @(posedge clk)
begin
    prev_rst <= rst;
    if(rst)
    begin
        finished <= 0;
        index <= 0;
    end
    else if((~finished) & (~tft_busy) & not_wait & (~set_wait_delay))
    begin
        if(init_sequence[index][9]) //WAIT
        begin
            set_wait_delay <= 1;
            wait_delay_value <= init_sequence[index][7:0];
        end
        else
        begin
            tft_transmit <= 1;
            tft_dc <= init_sequence[index][8];
            tft_data <= init_sequence[index][7:0];
        end
        index <= index + 1;
        if(index == 79)
            finished <= 1;
    end
    else
    begin
        set_wait_delay <= 0;
        tft_transmit <= 0;
    end
end

endmodule