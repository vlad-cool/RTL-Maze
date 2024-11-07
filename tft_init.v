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

localparam ticks_per_ms = 10000;
localparam[1:0] COMM = 2'b00;
localparam[1:0] DATA = 2'b01;
localparam[1:0] WAIT = 2'b10;

wire[9:0] init_sequence[31:0];
assign init_sequence[0]  = {COMM, 8'hc0};
assign init_sequence[1]  = {DATA, 8'h17};
assign init_sequence[2]  = {DATA, 8'h15};
assign init_sequence[3]  = {COMM, 8'hc1};
assign init_sequence[4]  = {DATA, 8'h41};
assign init_sequence[5]  = {COMM, 8'hc5};
assign init_sequence[6]  = {DATA, 8'h00};
assign init_sequence[7]  = {DATA, 8'h12};
assign init_sequence[8]  = {DATA, 8'h80};
assign init_sequence[9]  = {COMM, 8'h36};
assign init_sequence[10] = {DATA, 8'h48};
assign init_sequence[11] = {COMM, 8'h3a};
assign init_sequence[12] = {DATA, 8'h66};
assign init_sequence[13] = {COMM, 8'hb0};
assign init_sequence[14] = {DATA, 8'h80};
assign init_sequence[15] = {COMM, 8'hb1};
assign init_sequence[16] = {DATA, 8'ha0};
assign init_sequence[17] = {COMM, 8'hb6};
assign init_sequence[18] = {DATA, 8'h02};
assign init_sequence[19] = {DATA, 8'h02};
assign init_sequence[20] = {COMM, 8'he9};
assign init_sequence[21] = {DATA, 8'h00};
assign init_sequence[22] = {COMM, 8'hf7};
assign init_sequence[23] = {DATA, 8'ha9};
assign init_sequence[24] = {DATA, 8'h51};
assign init_sequence[25] = {DATA, 8'h2c};
assign init_sequence[26] = {DATA, 8'h82};
assign init_sequence[27] = {COMM, 8'h11};
assign init_sequence[28] = {WAIT, 8'hff};
assign init_sequence[29] = {COMM, 8'h29};
assign init_sequence[30] = {COMM, 8'h21};
assign init_sequence[31] = {COMM, 8'h34};

reg prev_rst;
reg[4:0] index;
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
)

always @(posedge clk)
begin
    prev_rst <= rst;
    if(prev_rst & (~rst))
    begin
        finished <= 0;
        index <= 0;
    end
    else if((~finished) & (~tft_busy) & not_wait)
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
        if(index == 31)
            finished <= 1;
    end
    else
    begin
        set_wait_delay <= 0;
        tft_transmit <= 0;
    end
end

endmodule