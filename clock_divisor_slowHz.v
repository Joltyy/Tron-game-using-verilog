module clock_divisor_slowHz(clk1, clk);
input clk;
output clk1;

reg [21:0] num;
wire [21:0] next_num;

always @(posedge clk) begin
  num <= next_num;
end

assign next_num = num + 1'b1;
assign clk1 = num[21];

endmodule