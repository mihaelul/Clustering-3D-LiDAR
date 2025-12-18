module fcc_fsm #(
  parameter W = 16,
  parameter LABEL_W = 16,
  parameter COLS = 2048,
  parameter COL_W = 11,
  parameter DCU_LAT = 3,
  parameter [39:0] EPS_H2 = 40'd2500,
  parameter [39:0] EPS_V2 = 40'd2500
)(
  input  wire                   clk,
  input  wire                   rst,

  // input stream (Range Image raster: row/col)
  input  wire                   in_valid,
  output wire                   in_ready,
  input  wire [7:0]             in_row,     // păstrează 8 biți, tu îl adaptezi la ROW_W
  input  wire [COL_W-1:0]       in_col,
  input  wire signed [W-1:0]    in_x, in_y, in_z,
  input  wire                   in_is_ground,

  // Line Buffer interface
  output wire                   mem_eol,
  output wire                   mem_we,
  output wire [COL_W-1:0]       mem_waddr,
  output wire signed [W-1:0]    mem_wx, mem_wy, mem_wz,
  output wire [LABEL_W-1:0]     mem_wlabel,
  output wire                   mem_wvalid,

  output wire [COL_W-1:0]       mem_raddr_m1,
  output wire [COL_W-1:0]       mem_raddr_0,
  output wire [COL_W-1:0]       mem_raddr_p1,
  input  wire signed [W-1:0]    mem_rx_m1, mem_ry_m1, mem_rz_m1,
  input  wire [LABEL_W-1:0]     mem_rlabel_m1,
  input  wire                   mem_rvalid_m1,
  input  wire signed [W-1:0]    mem_rx_0, mem_ry_0, mem_rz_0,
  input  wire [LABEL_W-1:0]     mem_rlabel_0,
  input  wire                   mem_rvalid_0,
  input  wire signed [W-1:0]    mem_rx_p1, mem_ry_p1, mem_rz_p1,
  input  wire [LABEL_W-1:0]     mem_rlabel_p1,
  input  wire                   mem_rvalid_p1,

  // merge requests către Union-Find (union a,b)
  output reg                    merge_valid,
  output reg  [LABEL_W-1:0]     merge_a,
  output reg  [LABEL_W-1:0]     merge_b,
  input  wire                   merge_ready,

  // query root pentru fiecare punct (label -> root)
  output reg                    q_valid,
  output reg  [LABEL_W-1:0]     q_label,
  input  wire                   q_ready,
  input  wire                   q_out_valid,
  input  wire [LABEL_W-1:0]     q_root,

  // output stream
  output reg                    out_valid,
  input  wire                   out_ready,
  output reg  [7:0]             out_row,
  output reg  [COL_W-1:0]       out_col,
  output reg  [LABEL_W-1:0]     out_label_root
);

  // accept când nu suntem blocați de output
  wire accept = in_valid && in_ready;
  assign in_ready = (!out_valid) || out_ready;

  // adrese read pentru fereastră 3×3 (doar rândul de sus: col-1, col, col+1)
  assign mem_raddr_m1 = (in_col==0) ? {COL_W{1'b0}} : (in_col - 1'b1);
  assign mem_raddr_0  = in_col;
  assign mem_raddr_p1 = (in_col==(COLS-1)) ? in_col : (in_col + 1'b1);

  // scriere cur row în line buffer
  assign mem_we    = accept;
  assign mem_waddr = in_col;
  assign mem_wx    = in_x;
  assign mem_wy    = in_y;
  assign mem_wz    = in_z;

  // Pass1 label (provizoriu)
  reg prev_valid;
  reg signed [W-1:0] prev_x, prev_y, prev_z;
  reg [LABEL_W-1:0]  prev_label;

  reg first_valid;
  reg signed [W-1:0] first_x, first_y, first_z;
  reg [LABEL_W-1:0]  first_label;

  reg [LABEL_W-1:0] next_label;
  reg [LABEL_W-1:0] p1_label;
  reg p1_valid_point;

  assign mem_wlabel = p1_label;
  assign mem_wvalid = p1_valid_point;

  assign mem_eol = accept && (in_col == (COLS-1));

  // dist2 combinational pentru Pass1 + ring-check (simplifică controlul)
  function [39:0] dist2_comb;
    input signed [W-1:0] ax, ay, az;
    input signed [W-1:0] bx, by, bz;
    reg signed [W:0] dx, dy, dz;
    reg [33:0] sx, sy, sz;
    begin
      dx = ax - bx; dy = ay - by; dz = az - bz;
      sx = dx*dx; sy = dy*dy; sz = dz*dz;
      dist2_comb = sx + sy + sz;
    end
  endfunction

  // Pass2 DCU-uri (3 vecini de sus)
  wire dcu_in_valid = accept && !in_is_ground;

  wire v_m1, v_0, v_p1;
  wire [39:0] d2_m1, d2_0, d2_p1;

  fcc_distance_unit #(.W(W)) dcu_m1 (
    .clk(clk), .rst(rst),
    .in_valid(dcu_in_valid && mem_rvalid_m1),
    .ax(in_x), .ay(in_y), .az(in_z),
    .bx(mem_rx_m1), .by(mem_ry_m1), .bz(mem_rz_m1),
    .out_valid(v_m1), .dist2(d2_m1)
  );

  fcc_distance_unit #(.W(W)) dcu_0 (
    .clk(clk), .rst(rst),
    .in_valid(dcu_in_valid && mem_rvalid_0),
    .ax(in_x), .ay(in_y), .az(in_z),
    .bx(mem_rx_0), .by(mem_ry_0), .bz(mem_rz_0),
    .out_valid(v_0), .dist2(d2_0)
  );

  fcc_distance_unit #(.W(W)) dcu_p1 (
    .clk(clk), .rst(rst),
    .in_valid(dcu_in_valid && mem_rvalid_p1),
    .ax(in_x), .ay(in_y), .az(in_z),
    .bx(mem_rx_p1), .by(mem_ry_p1), .bz(mem_rz_p1),
    .out_valid(v_p1), .dist2(d2_p1)
  );

  // aliniere label-uri cu latența DCU (doc spune să întârziem label/valid în paralel) :contentReference[oaicite:7]{index=7}
  reg [LABEL_W-1:0] cur_label_d [0:DCU_LAT-1];
  reg [LABEL_W-1:0] nb_m1_d [0:DCU_LAT-1];
  reg [LABEL_W-1:0] nb_0_d  [0:DCU_LAT-1];
  reg [LABEL_W-1:0] nb_p1_d [0:DCU_LAT-1];
  reg cur_v_d [0:DCU_LAT-1];

  integer k;
  always @(posedge clk) begin
    if (rst) begin
      for (k=0; k<DCU_LAT; k=k+1) begin
        cur_label_d[k] <= 0;
        nb_m1_d[k] <= 0;
        nb_0_d[k]  <= 0;
        nb_p1_d[k] <= 0;
        cur_v_d[k] <= 1'b0;
      end
    end else begin
      cur_label_d[0] <= p1_label;
      nb_m1_d[0] <= mem_rlabel_m1;
      nb_0_d[0]  <= mem_rlabel_0;
      nb_p1_d[0] <= mem_rlabel_p1;
      cur_v_d[0] <= (accept && !in_is_ground);

      for (k=1; k<DCU_LAT; k=k+1) begin
        cur_label_d[k] <= cur_label_d[k-1];
        nb_m1_d[k] <= nb_m1_d[k-1];
        nb_0_d[k]  <= nb_0_d[k-1];
        nb_p1_d[k] <= nb_p1_d[k-1];
        cur_v_d[k] <= cur_v_d[k-1];
      end
    end
  end

  // output pending (așteptăm root de la UF)
  reg pending;
  reg [7:0] pend_row;
  reg [COL_W-1:0] pend_col;
  reg [LABEL_W-1:0] pend_label;

  always @(posedge clk) begin
    if (rst) begin
      prev_valid <= 1'b0;
      first_valid <= 1'b0;
      prev_x <= 0; prev_y <= 0; prev_z <= 0;
      first_x <= 0; first_y <= 0; first_z <= 0;
      prev_label <= 0; first_label <= 0;
      next_label <= 16'd1;

      p1_label <= 0;
      p1_valid_point <= 1'b0;

      merge_valid <= 1'b0;
      merge_a <= 0; merge_b <= 0;

      q_valid <= 1'b0;
      q_label <= 0;

      pending <= 1'b0;
      out_valid <= 1'b0;
      out_row <= 0;
      out_col <= 0;
      out_label_root <= 0;
    end else begin
      merge_valid <= 1'b0;
      q_valid <= 1'b0;

      // consum output
      if (out_valid && out_ready) out_valid <= 1'b0;

      // început de rând: resetăm Pass1 state
      if (accept && (in_col==0)) begin
        prev_valid <= 1'b0;
        first_valid <= 1'b0;
      end

      // Pass1 label assign + ring buffers
      if (accept) begin
        if (in_is_ground) begin
          p1_valid_point <= 1'b0;
          prev_valid <= 1'b0; // ground rupe conectivitatea
        end else begin
          p1_valid_point <= 1'b1;

          if (prev_valid && (dist2_comb(in_x,in_y,in_z, prev_x,prev_y,prev_z) < EPS_H2))
            p1_label <= prev_label;
          else begin
            p1_label <= next_label;
            next_label <= next_label + 1'b1;
          end

          if (!first_valid) begin
            first_valid <= 1'b1;
            first_x <= in_x; first_y <= in_y; first_z <= in_z;
            first_label <= (prev_valid && (dist2_comb(in_x,in_y,in_z, prev_x,prev_y,prev_z) < EPS_H2))
                           ? prev_label : next_label;
          end

          prev_valid <= 1'b1;
          prev_x <= in_x; prev_y <= in_y; prev_z <= in_z;
          prev_label <= (prev_valid && (dist2_comb(in_x,in_y,in_z, prev_x,prev_y,prev_z) < EPS_H2))
                        ? prev_label : next_label;
        end

        // lansăm query pentru label root (un punct pe rând)
        if (!in_is_ground && q_ready) begin
          q_valid <= 1'b1;
          q_label <= p1_label;

          pending <= 1'b1;
          pend_row <= in_row;
          pend_col <= in_col;
          pend_label <= p1_label;
        end
      end

      // Pass2: merge vertical (după DCU_LAT), dacă UF poate primi
      if (merge_ready && cur_v_d[DCU_LAT-1]) begin
        if (v_0 && (d2_0 < EPS_V2)) begin
          merge_valid <= 1'b1;
          merge_a <= cur_label_d[DCU_LAT-1];
          merge_b <= nb_0_d[DCU_LAT-1];
        end else if (v_m1 && (d2_m1 < EPS_V2)) begin
          merge_valid <= 1'b1;
          merge_a <= cur_label_d[DCU_LAT-1];
          merge_b <= nb_m1_d[DCU_LAT-1];
        end else if (v_p1 && (d2_p1 < EPS_V2)) begin
          merge_valid <= 1'b1;
          merge_a <= cur_label_d[DCU_LAT-1];
          merge_b <= nb_p1_d[DCU_LAT-1];
        end
      end

      // ring-check la EOL (dacă putem trimite merge)
      if (merge_ready && accept && (in_col==(COLS-1)) && prev_valid && first_valid) begin
        if (dist2_comb(prev_x,prev_y,prev_z, first_x,first_y,first_z) < EPS_H2) begin
          merge_valid <= 1'b1;
          merge_a <= prev_label;
          merge_b <= first_label;
        end
      end

      // când vine root -> scoatem output
      if (q_out_valid && pending && (!out_valid || out_ready)) begin
        out_valid <= 1'b1;
        out_row <= pend_row;
        out_col <= pend_col;
        out_label_root <= q_root;
        pending <= 1'b0;
      end
    end
  end
endmodule
