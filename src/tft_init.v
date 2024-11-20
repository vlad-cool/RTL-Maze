// by Aleksandr
// Transmit init sequence & select all screen to draw the scene.

module tft_init
(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire tft_busy,

    output reg tft_dc,
    output reg[7:0] tft_data,
    output reg tft_transmit,
    output wire busy
);

localparam DC_COUNT = 47;
localparam[1:0] COMM = 2'b00;
localparam[1:0] DATA = 2'b01;
localparam[1:0] WAIT = 2'b10;

wire[9:0] init_sequence[(DC_COUNT - 1):0];
assign init_sequence[0]  = {WAIT, 8'hff};
assign init_sequence[1]  = {COMM, 8'hc0};
assign init_sequence[2]  = {DATA, 8'h17};
assign init_sequence[3]  = {DATA, 8'h15};
assign init_sequence[4]  = {COMM, 8'hc1};
assign init_sequence[5]  = {DATA, 8'h41};
assign init_sequence[6]  = {COMM, 8'hc5};
assign init_sequence[7]  = {DATA, 8'h00};
assign init_sequence[8]  = {DATA, 8'h12};
assign init_sequence[9]  = {DATA, 8'h80};
assign init_sequence[10] = {COMM, 8'h36};
assign init_sequence[11] = {DATA, 8'h48};
assign init_sequence[12] = {COMM, 8'h3a};
assign init_sequence[13] = {DATA, 8'h66};
assign init_sequence[14] = {COMM, 8'hb0};
assign init_sequence[15] = {DATA, 8'h80};
assign init_sequence[16] = {COMM, 8'hb1};
assign init_sequence[17] = {DATA, 8'ha0};
assign init_sequence[18] = {COMM, 8'hb6};
assign init_sequence[19] = {DATA, 8'h02};
assign init_sequence[20] = {DATA, 8'h02};
assign init_sequence[21] = {COMM, 8'he9};
assign init_sequence[22] = {DATA, 8'h00};
assign init_sequence[23] = {COMM, 8'hf7};
assign init_sequence[24] = {DATA, 8'ha9};
assign init_sequence[25] = {DATA, 8'h51};
assign init_sequence[26] = {DATA, 8'h2c};
assign init_sequence[27] = {DATA, 8'h82};
assign init_sequence[28] = {COMM, 8'h11};
assign init_sequence[29] = {WAIT, 8'hff};
assign init_sequence[30] = {COMM, 8'h29};
assign init_sequence[31] = {COMM, 8'h00};
assign init_sequence[32] = {COMM, 8'h34};
//wait initialization
assign init_sequence[33] = {WAIT, 8'hff};
//select full screen
assign init_sequence[34] = {COMM, 8'h2a};
assign init_sequence[35] = {DATA, 8'h00};
assign init_sequence[36] = {DATA, 8'h00};
assign init_sequence[37] = {DATA, 8'h01};
assign init_sequence[38] = {DATA, 8'h3f};
assign init_sequence[39] = {COMM, 8'h2b};
assign init_sequence[40] = {DATA, 8'h00};
assign init_sequence[41] = {DATA, 8'h00};
assign init_sequence[42] = {DATA, 8'h01};
assign init_sequence[43] = {DATA, 8'hdf};
//start drawing
assign init_sequence[44] = {COMM, 8'h2c};
//nop
assign init_sequence[45] = {WAIT, 8'h00};

reg[7:0] index;
reg set_wait_delay;
reg[7:0] wait_delay_value;
wire not_wait;

assign busy = (index < DC_COUNT) & enable;

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
    if(rst)
    begin
        index <= 0;
        set_wait_delay <= 0;
        tft_transmit <= 0;
    end
    else if(busy & (~tft_busy) & (~tft_transmit) & not_wait & (~set_wait_delay))
    begin
        if(init_sequence[index][9]) //WAIT bit
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
    end
    else
    begin
        set_wait_delay <= 0;
        tft_transmit <= 0;
    end
end

endmodule
