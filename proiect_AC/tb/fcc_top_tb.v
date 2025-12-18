`timescale 1ns/1ps

module fcc_top_tb;
  reg clk = 0;
  reg rst = 1;
  always #5 clk = ~clk;

  localparam W    = 16;
  localparam ROWS = 30;
  localparam COLS = 30;
  localparam COL_W = 5;   // suficient pt 0..29
  localparam LABEL_W = 16;

  // --- DUT inputs ---
  reg  in_valid;
  wire in_ready;
  reg  [7:0] in_row;
  reg  [COL_W-1:0] in_col;
  reg  signed [W-1:0] in_x, in_y, in_z;
  reg  in_is_ground;

  // --- DUT outputs ---
  wire out_valid;
  wire out_ready;                 // IMPORTANT: WIRE (iesire din DUT)
  wire [7:0] out_row;
  wire [COL_W-1:0] out_col;
  wire [LABEL_W-1:0] out_label_root;

  integer fd;
  integer out_cnt;

  // memorie locală pentru coordonate (row,col)->(x,y,z)
  reg signed [W-1:0] store_x [0:ROWS*COLS-1];
  reg signed [W-1:0] store_y [0:ROWS*COLS-1];
  reg signed [W-1:0] store_z [0:ROWS*COLS-1];

  function integer idx;
    input [7:0] r;
    input [COL_W-1:0] c;
    begin
      idx = r*COLS + c;
    end
  endfunction

  // noise mic [-3..+3]
  function signed [W-1:0] n7;
    input integer t;
    begin
      n7 = (t % 7) - 3;
    end
  endfunction

  // 5 centre 3D (separate)
  function signed [W-1:0] cx; input integer k;
    begin case(k)
      0: cx=15; 1: cx=35; 2: cx=55; 3: cx=75; default: cx=45;
    endcase end
  endfunction

  function signed [W-1:0] cy; input integer k;
    begin case(k)
      0: cy=15; 1: cy=35; 2: cy=15; 3: cy=55; default: cy=45;
    endcase end
  endfunction

  function signed [W-1:0] cz; input integer k;
    begin case(k)
      0: cz=10; 1: cz=25; 2: cz=10; 3: cz=60; default: cz=40;
    endcase end
  endfunction

  // patch-uri compacte în grid (row/col)
  function integer patch_id;
    input integer rr, cc;
    begin
      if      (rr>=2  && rr<10 && cc>=2  && cc<10 ) patch_id = 0;
      else if (rr>=2  && rr<10 && cc>=12 && cc<20) patch_id = 1;
      else if (rr>=12 && rr<20 && cc>=2  && cc<10 ) patch_id = 2;
      else if (rr>=12 && rr<20 && cc>=12 && cc<20) patch_id = 3;
      else if (rr>=22 && rr<30 && cc>=8  && cc<16) patch_id = 4;
      else patch_id = -1;
    end
  endfunction

  // --- DUT instantiation ---
  fcc_top #(
    .W(W),
    .LABEL_W(LABEL_W),
    .COLS(COLS),
    .COL_W(COL_W),
    .UF_MAX_LABELS(4096),

    // poți ajusta; 400 = 20^2 (leagă sigur)
    .EPS_H2(40'd400),
    .EPS_V2(40'd400)
  ) dut (
    .clk(clk),
    .rst(rst),

    .in_valid(in_valid),
    .in_ready(in_ready),
    .in_row(in_row),
    .in_col(in_col),
    .in_x(in_x),
    .in_y(in_y),
    .in_z(in_z),
    .in_is_ground(in_is_ground),

    .out_valid(out_valid),
    .out_ready(out_ready),
    .out_row(out_row),
    .out_col(out_col),
    .out_label_root(out_label_root)
  );

  integer r, c;
  integer k;
  integer seed;
  reg signed [W-1:0] dx, dy, dz;

  initial begin
    in_valid = 0;
    in_row = 0;
    in_col = 0;
    in_x = 0; in_y = 0; in_z = 0;
    in_is_ground = 1;

    out_cnt = 0;

    fd = $fopen("../fcc_clusters_out.txt", "w");
    if (fd == 0) begin
      $display("NU pot deschide ../fcc_clusters_out.txt");
      $finish;
    end

    // init local store
    for (r=0; r<ROWS; r=r+1)
      for (c=0; c<COLS; c=c+1) begin
        store_x[idx(r[7:0], c[COL_W-1:0])] = 0;
        store_y[idx(r[7:0], c[COL_W-1:0])] = 0;
        store_z[idx(r[7:0], c[COL_W-1:0])] = 0;
      end

    #30 rst = 0;

    // trimite frame complet (ROWS*COLS)
    for (r = 0; r < ROWS; r = r + 1) begin
      for (c = 0; c < COLS; c = c + 1) begin
        @(posedge clk);
        if (in_ready) begin
          in_valid <= 1'b1;
          in_row   <= r[7:0];
          in_col   <= c[COL_W-1:0];

          k = patch_id(r, c);
          if (k >= 0) begin
            seed = r*31 + c*17 + k*101;
            dx = n7(seed);
            dy = n7(seed+3);
            dz = n7(seed+5);

            in_is_ground <= 1'b0;
            in_x <= cx(k) + dx;
            in_y <= cy(k) + dy;
            in_z <= cz(k) + dz;

            store_x[idx(r[7:0], c[COL_W-1:0])] <= cx(k) + dx;
            store_y[idx(r[7:0], c[COL_W-1:0])] <= cy(k) + dy;
            store_z[idx(r[7:0], c[COL_W-1:0])] <= cz(k) + dz;
          end else begin
            in_is_ground <= 1'b1;
            in_x <= 0; in_y <= 0; in_z <= 0;

            store_x[idx(r[7:0], c[COL_W-1:0])] <= 0;
            store_y[idx(r[7:0], c[COL_W-1:0])] <= 0;
            store_z[idx(r[7:0], c[COL_W-1:0])] <= 0;
          end
        end else begin
          in_valid <= 1'b0;
        end
      end
    end

    @(posedge clk);
    in_valid <= 1'b0;

    // timp pentru dump/output din DUT
    repeat (30000) @(posedge clk);

    $fclose(fd);
    $display("Scris: ../fcc_clusters_out.txt");
    $display("OUT_REAL_WRITTEN = %0d", out_cnt);
    $finish;
  end

  // scriem DOAR puncte reale (≠0,0,0)
  always @(posedge clk) begin
    if (out_valid) begin
      if (store_x[idx(out_row,out_col)] != 0 ||
          store_y[idx(out_row,out_col)] != 0 ||
          store_z[idx(out_row,out_col)] != 0) begin

        out_cnt = out_cnt + 1;

        $fwrite(fd, "%0d %0d %0d %0d\n",
          store_x[idx(out_row,out_col)],
          store_y[idx(out_row,out_col)],
          store_z[idx(out_row,out_col)],
          out_label_root
        );
      end
    end
  end

endmodule
