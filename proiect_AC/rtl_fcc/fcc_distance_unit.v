module fcc_distance_unit #(
  parameter W = 16
)(
  input  wire               clk,
  input  wire               rst,
  input  wire               in_valid,
  input  wire signed [W-1:0] ax, ay, az,
  input  wire signed [W-1:0] bx, by, bz,
  output reg                out_valid,
  output reg  [39:0]        dist2
);
  reg signed [W:0] dx1, dy1, dz1;
  reg [33:0] dx2, dy2, dz2;

  always @(posedge clk) begin
    if (rst) begin
      out_valid <= 1'b0;
      dist2 <= 40'd0;
      dx1 <= 0; dy1 <= 0; dz1 <= 0;
      dx2 <= 0; dy2 <= 0; dz2 <= 0;
    end else begin
      // stage 1
      dx1 <= ax - bx;
      dy1 <= ay - by;
      dz1 <= az - bz;

      // stage 2
      dx2 <= dx1 * dx1;
      dy2 <= dy1 * dy1;
      dz2 <= dz1 * dz1;

      // stage 3
      dist2 <= dx2 + dy2 + dz2;
      out_valid <= in_valid;
    end
  end
endmodule
