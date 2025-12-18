module fcc_union_find #(
  parameter LABEL_W = 16,
  parameter MAX_LABELS = 65536
)(
  input  wire                   clk,
  input  wire                   rst,

  // union request
  input  wire                   u_valid,
  output wire                   u_ready,
  input  wire [LABEL_W-1:0]     u_a,
  input  wire [LABEL_W-1:0]     u_b,

  // query root
  input  wire                   q_valid,
  output wire                   q_ready,
  input  wire [LABEL_W-1:0]     q_label,
  output reg                    q_out_valid,
  output reg  [LABEL_W-1:0]     q_root
);
  reg [LABEL_W-1:0] parent [0:MAX_LABELS-1];

  localparam S_IDLE=0, S_FIND_A=1, S_FIND_B=2, S_DO_UNION=3, S_Q_FIND=4;
  reg [2:0] state;

  reg [LABEL_W-1:0] cur;
  reg [LABEL_W-1:0] root_a, root_b;
  reg [LABEL_W-1:0] start_a, start_b;
  reg [LABEL_W-1:0] q_start;

  assign u_ready = (state == S_IDLE);
  assign q_ready = (state == S_IDLE) && !u_valid; // prioritate union

  integer i;
  always @(posedge clk) begin
    if (rst) begin
      state <= S_IDLE;
      q_out_valid <= 1'b0;
      q_root <= 0;
      for (i=0; i<MAX_LABELS; i=i+1) parent[i] <= i[LABEL_W-1:0];
    end else begin
      q_out_valid <= 1'b0;

      case (state)
        S_IDLE: begin
          if (u_valid) begin
            start_a <= u_a; start_b <= u_b;
            cur <= u_a;
            state <= S_FIND_A;
          end else if (q_valid) begin
            q_start <= q_label;
            cur <= q_label;
            state <= S_Q_FIND;
          end
        end

        S_FIND_A: begin
          if (parent[cur] == cur) begin
            root_a <= cur;
            parent[start_a] <= cur; // compression light
            cur <= start_b;
            state <= S_FIND_B;
          end else cur <= parent[cur];
        end

        S_FIND_B: begin
          if (parent[cur] == cur) begin
            root_b <= cur;
            parent[start_b] <= cur;
            state <= S_DO_UNION;
          end else cur <= parent[cur];
        end

        S_DO_UNION: begin
          if (root_a != root_b) begin
            if (root_a < root_b) parent[root_b] <= root_a;
            else                 parent[root_a] <= root_b;
          end
          state <= S_IDLE;
        end

        S_Q_FIND: begin
          if (parent[cur] == cur) begin
            q_root <= cur;
            parent[q_start] <= cur;
            q_out_valid <= 1'b1;
            state <= S_IDLE;
          end else cur <= parent[cur];
        end
      endcase
    end
  end
endmodule
