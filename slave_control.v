module slave_control(
    input clk,
    input rst,
//    input [3:0] vgaRed_in,
//    input [3:0] vgaGreen_in,
//    input [3:0] vgaBlue_in,
//    input hsync_in,
//    input vsync_in,
    inout PS2_DATA,
    inout PS2_CLK,
//    output reg [3:0] vgaRed,
//    output reg [3:0] vgaGreen,
//    output reg [3:0] vgaBlue,
    output reg [3:0] key_out, // 4-bit output for i, j, k, l keys
    output reg led_i,
    output reg led_j,
    output reg led_k,
    output reg led_l,
    output reg led_rst
//    output hsync,
//    output vsync
);

wire [511:0] key_down_internal;
wire [8:0] last_change_internal;
wire key_valid_internal;
reg [3:0] next_key_out;

// Instantiate the Keyboard Decoder
keyboardDecoder key_de (
    .key_down(key_down_internal),
    .last_change(last_change_internal),
    .key_valid(key_valid_internal),
    .PS2_DATA(PS2_DATA),
    .PS2_CLK(PS2_CLK),
    .rst(rst),
    .clk(clk)
);

always@(posedge clk or posedge rst) begin
    if(rst) begin
        key_out <= 4'b0000;
    end else begin
        key_out <= next_key_out;
    end
end
// Keyboard Movement
always @(*) begin
    if (rst) begin
        led_i = 0;
        led_j = 0;
        led_k = 0;
        led_l = 0;
        next_key_out = 4'b0000;
    end else begin
        if (key_down_internal[8'h43]) next_key_out = 4'b1000;
        else if (key_down_internal[8'h3B]) next_key_out = 4'b0100;
        else if (key_down_internal[8'h42]) next_key_out = 4'b0010;
        else if (key_down_internal[8'h4B]) next_key_out = 4'b0001;
        else begin
            next_key_out = key_out;
        end


        led_i = key_down_internal[8'h43];
        led_j = key_down_internal[8'h3B];
        led_k = key_down_internal[8'h42];
        led_l = key_down_internal[8'h4B];

        led_rst = 0;
    end
end



endmodule