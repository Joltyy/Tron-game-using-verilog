module seven_seg_display(
    input clk,
    input rst,
    input [3:0] player1_score_tens,
    input [3:0] player1_score_units,
    input [3:0] player2_score_tens,
    input [3:0] player2_score_units,
    output reg [3:0] an,
    output reg [6:0] sevenseg
);

reg [1:0] digit_select;
reg [3:0] current_digit;
reg [16:0] refresh_counter;

always @(*) begin
    case (current_digit)
        4'd0: sevenseg = 7'b1000000; // 0
        4'd1: sevenseg = 7'b1111001; // 1
        4'd2: sevenseg = 7'b0100100; // 2
        4'd3: sevenseg = 7'b0110000; // 3
        4'd4: sevenseg = 7'b0011001; // 4
        4'd5: sevenseg = 7'b0010010; // 5
        4'd6: sevenseg = 7'b0000010; // 6
        4'd7: sevenseg = 7'b1111000; // 7
        4'd8: sevenseg = 7'b0000000; // 8
        4'd9: sevenseg = 7'b0010000; // 9
        default: sevenseg = 7'b1111111; // Blank
    endcase
end

// Refresh counter and digit select
always @(posedge clk or posedge rst) begin
    if (rst) begin
        refresh_counter <= 0;
        digit_select <= 0;
    end else begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter == 19'd100_000) begin
            refresh_counter <= 0;
            digit_select <= digit_select + 1;
        end
    end
end

// Multiplexing logic
always @(*) begin
    case (digit_select)
        2'b00: begin
            an = 4'b1011;
            current_digit = player1_score_units;
        end
        2'b01: begin
            an = 4'b0111;
            current_digit = player1_score_tens;
        end
        2'b10: begin
            an = 4'b1110;
            current_digit = player2_score_units;
        end
        2'b11: begin
            an = 4'b1101;
            current_digit = player2_score_tens;
        end
        default: begin
            an = 4'b1111;
            current_digit = 4'b0000;
        end
    endcase
end

endmodule