module top(
  input clk,
  input rst,
  input [3:0] key_in,
  output [3:0] vgaRed,
  output [3:0] vgaGreen,
  output [3:0] vgaBlue,
  output hsync,
  output vsync,
  inout PS2_DATA,
  inout PS2_CLK,
  output [1:0] player1_dir_out,
  output [1:0] player2_dir_out,
  output reg led_key_valid,
  output led_w,
  output led_a,
  output led_s,
  output led_d,
  output [3:0] an_digit,
  output [6:0] sevenseg,
  // output [3:0] vgaRed_dup,
  // output [3:0] vgaGreen_dup,
  // output [3:0] vgaBlue_dup,
  // output hsync_dup,,
  // output vsync_dup,
  output clk_dup,
  output rst_dup
);


wire clk_25MHz;
wire valid;
wire [9:0] h_cnt; //640
wire [9:0] v_cnt;  //480
wire [511:0] key_down;
wire [8:0] last_change;
wire key_valid;
wire [3:0] player1_score_tens;
wire [3:0] player1_score_units;
wire [3:0] player2_score_tens;
wire [3:0] player2_score_units;

clock_divisor clk_wiz_0_inst(
  .clk(clk),
  .clk1(clk_25MHz)
);

vga_controller   vga_inst(
  .pclk(clk_25MHz),
  .reset(rst),
  .hsync(hsync),
  .vsync(vsync),
  .valid(valid),
  .h_cnt(h_cnt),
  .v_cnt(v_cnt)
);

keyboardDecoder key_de (
  .key_down(key_down),
  .last_change(last_change),
  .key_valid(key_valid),
  .PS2_DATA(PS2_DATA),
  .PS2_CLK(PS2_CLK),
  .rst(rst),
  .clk(clk_25MHz)
);

game_logic game_lgc(
  .clk_25MHz(clk_25MHz),
  .rst(rst),
  .h_cnt(h_cnt),
  .v_cnt(v_cnt),
  .vgaRed(vgaRed),
  .vgaGreen(vgaGreen),
  .vgaBlue(vgaBlue),
  .valid(valid),
  .key_down(key_down),
  .last_change(last_change),
  .key_valid(key_valid),
  .player1_dir(player1_dir_out),
  .player2_dir(player2_dir_out),
  .led_w(led_w),
  .led_a(led_a),
  .led_s(led_s),
  .led_d(led_d),
  .player1_score_tens(player1_score_tens),
  .player1_score_units(player1_score_units),
  .player2_score_tens(player2_score_tens),
  .player2_score_units(player2_score_units),
  .key_in(key_in)
);

seven_seg_display seven_seg(
  .clk(clk_25MHz),
  .rst(rst),
  .player1_score_tens(player1_score_tens),
  .player1_score_units(player1_score_units),
  .player2_score_tens(player2_score_tens),
  .player2_score_units(player2_score_units),
  .an(an_digit),
  .sevenseg(sevenseg)
);

// assign vgaRed_dup = vgaRed;
// assign vgaGreen_dup = vgaGreen;
// assign vgaBlue_dup = vgaBlue;
assign clk_dup = clk_25MHz;
assign rst_dup = rst;
// assign hsync_dup = hsync;
// assign vsync_dup = vsync;

// Debounce mechanism for key_valid signal
reg [19:0] debounce_counter;
always @(posedge clk or posedge rst) begin
  if (rst) begin
    debounce_counter <= 0;
    led_key_valid <= 0;
  end else if (key_valid) begin
    debounce_counter <= 19'hFFFFF; // Set counter to maximum value
    led_key_valid <= 1;
  end else if (debounce_counter > 0) begin
    debounce_counter <= debounce_counter - 1;
    if (debounce_counter == 1) begin
      led_key_valid <= 0;
    end
  end
end
      
endmodule
