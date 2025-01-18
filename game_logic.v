module game_logic(
    input clk_25MHz,
    input rst,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue,
    input valid,
    input [511:0] key_down,
    input [8:0] last_change,
    input key_valid,
    output reg [1:0] player1_dir,
    output reg [1:0] player2_dir,
    output reg led_w,
    output reg led_a,
    output reg led_s,
    output reg led_d,
    output reg [3:0] player1_score_tens,
    output reg [3:0] player1_score_units,
    output reg [3:0] player2_score_tens,
    output reg [3:0] player2_score_units,
    input [3:0] key_in
);

wire clk_slowHz;

clock_divisor_slowHz clk_wiz_1_inst(
  .clk(clk_25MHz),
  .clk1(clk_slowHz)
);

reg [4:0] player1_x, player1_y;
reg [4:0] player2_x, player2_y;
reg [4:0] next_player1_x, next_player1_y;
reg [4:0] next_player2_x, next_player2_y;

//00 = up, 01 = right, 10 = left, 11 = down
reg [1:0] next_player1_dir, next_player2_dir;

//2d array for the map
// 000 = empty, 001 = player 1, 010 = player 2, 011 = trail 1, 100 = trail 2
reg [2:0] game_area [23:0][31:0];

parameter [7:0] KEY_W = 8'h1D;
parameter [7:0] KEY_A = 8'h1C;
parameter [7:0] KEY_S = 8'h1B;
parameter [7:0] KEY_D = 8'h23;
parameter [7:0] KEY_UP = 8'h43;
parameter [7:0] KEY_DOWN = 8'h42;
parameter [7:0] KEY_LEFT = 8'h3B;
parameter [7:0] KEY_RIGHT = 8'h4B;

//score tracker
reg [3:0] player1_score_tens, player1_score_units;
reg [3:0] player2_score_tens, player2_score_units;

integer i, j;

always @(posedge clk_slowHz or posedge rst) begin
    if (rst) begin
        player1_x <= 5;
        player1_y <= 8;
        player2_x <= 25;
        player2_y <= 8;

        player1_score_tens <= 4'b0000;
        player1_score_units <= 4'b0000;
        player2_score_tens <= 4'b0000;
        player2_score_units <= 4'b0000;

        for(i = 0; i < 24; i = i + 1) begin
            for(j = 0; j < 32; j = j + 1) begin
                game_area[i][j] <= 3'b000;
            end
        end

        game_area[8][5] <= 3'b001; // Player 1
        game_area[8][25] <= 3'b010; // Player 2
    end else begin
        // Mark the current positions as trails
        if (game_area[player1_y][player1_x] == 3'b001) begin
            game_area[player1_y][player1_x] <= 3'b011; // Trail 1
        end
        if (game_area[player2_y][player2_x] == 3'b010) begin
            game_area[player2_y][player2_x] <= 3'b100; // Trail 2
        end

        // Update player positions
        case (player1_dir)
             2'b00: begin next_player1_y = (player1_y == 0) ? 23 : player1_y - 1; next_player1_x = player1_x; end // Move up
            2'b01: begin next_player1_x = (player1_x == 31) ? 0 : player1_x + 1; next_player1_y = player1_y; end // Move right
            2'b10: begin next_player1_x = (player1_x == 0) ? 31 : player1_x - 1; next_player1_y = player1_y; end // Move left
            2'b11: begin next_player1_y = (player1_y == 23) ? 0 : player1_y + 1; next_player1_x = player1_x; end // Move down
        endcase
        case (player2_dir)
            2'b00: begin next_player2_y = (player2_y == 0) ? 23 : player2_y - 1; next_player2_x = player2_x; end // Move up
            2'b01: begin next_player2_x = (player2_x == 31) ? 0 : player2_x + 1; next_player2_y = player2_y; end // Move right
            2'b10: begin next_player2_x = (player2_x == 0) ? 31 : player2_x - 1; next_player2_y = player2_y; end // Move left
            2'b11: begin next_player2_y = (player2_y == 23) ? 0 : player2_y + 1; next_player2_x = player2_x; end // Move down
        endcase

        if ((game_area[next_player1_y][next_player1_x] != 3'b000) || // Player 1 collides trail
            (game_area[next_player2_y][next_player2_x] != 3'b000) || // Player 2 collides trail
            ((next_player1_x == next_player2_x) && (next_player1_y == next_player2_y))) // Players collide with each other
        begin
            // Update scores
            if (game_area[next_player1_y][next_player1_x] == 3'b000) begin
                player1_score_units <= (player1_score_units == 9) ? 0 : player1_score_units + 1;
                if (player1_score_units == 9) player1_score_tens <= player1_score_tens + 1;
            end
            if (game_area[next_player2_y][next_player2_x] == 3'b000) begin
                player2_score_units <= (player2_score_units == 9) ? 0 : player2_score_units + 1;
                if (player2_score_units == 9) player2_score_tens <= player2_score_tens + 1;
            end

            // Reset on collision
            player1_x <= 5;
            player1_y <= 8;
            player2_x <= 25;
            player2_y <= 8;

            for (i = 0; i < 24; i = i + 1) begin
                for (j = 0; j < 32; j = j + 1) begin
                    game_area[i][j] <= 3'b000;
                end
            end

            game_area[8][5] <= 3'b001;  // Player 1
            game_area[8][25] <= 3'b010; // Player 2
        end else begin
            player1_x <= next_player1_x;
            player1_y <= next_player1_y;
            player2_x <= next_player2_x;
            player2_y <= next_player2_y;

            // Mark the new positions
            game_area[next_player1_y][next_player1_x] <= 3'b001; // Player 1
            game_area[next_player2_y][next_player2_x] <= 3'b010; // Player 2
        end
    end
end

// Keyboard Movement
always @(*) begin
    if (rst) begin
        led_w = 0;
        led_a = 0;
        led_s = 0;
        led_d = 0;
        next_player1_dir = 2'b00;
        next_player2_dir = 2'b00;
    end else begin
        if (key_down[KEY_W]) next_player1_dir = 2'b00;
        else if (key_down[KEY_A]) next_player1_dir = 2'b10;
        else if (key_down[KEY_S]) next_player1_dir = 2'b11;
        else if (key_down[KEY_D]) next_player1_dir = 2'b01;
        else begin
            next_player1_dir = player1_dir;
        end

        if (key_in[3]) next_player2_dir = 2'b00;
        else if (key_in[2]) next_player2_dir = 2'b10;
        else if (key_in[1]) next_player2_dir = 2'b11;
        else if (key_in[0]) next_player2_dir = 2'b01;
        else begin
            next_player2_dir = player2_dir;
        end

        led_w = key_in[3];
        led_a = key_in[2];
        led_s = key_in[1];
        led_d = key_in[0];
    end
end

always @(posedge clk_25MHz) begin
    if(rst) begin
        player1_dir <= 2'b00;
        player2_dir <= 2'b00;
    end else begin
        player1_dir <= next_player1_dir;
        player2_dir <= next_player2_dir;
    end
end

// Draw to screen
integer block_x, block_y;
always @(*) begin
    if(!valid) begin
        vgaRed = 4'b0000;
        vgaGreen = 4'b0000;
        vgaBlue = 4'b0000;
    end else begin
        block_x = (h_cnt / 20);
        block_y = (v_cnt / 20);

        // Draw players
        case (game_area[block_y][block_x])
            3'b001: begin // Player 1
                vgaRed = 4'b1111;
                vgaGreen = 4'b0000;
                vgaBlue = 4'b0000;
            end
            3'b010: begin // Player 2
                vgaRed = 4'b0000;
                vgaGreen = 4'b1111;
                vgaBlue = 4'b0000;
            end
            3'b011: begin // Trail 1
                vgaRed = 4'b1000;
                vgaGreen = 4'b0000;
                vgaBlue = 4'b0000;
            end
            3'b100: begin // Trail 2
                vgaRed = 4'b0000;
                vgaGreen = 4'b1000;
                vgaBlue = 4'b0000;
            end
            default: begin // Empty
                vgaRed = 4'b0000;
                vgaGreen = 4'b0000;
                vgaBlue = 4'b0000;
            end
        endcase
    end
end
endmodule

