module dbscan_point_memory #(
    parameter MAX_N = 64
)(
    input clk,

    input [$clog2(MAX_N)-1:0] raddr_i,
    input [$clog2(MAX_N)-1:0] raddr_j,

    output [7:0] xi, yi, zi,
    output [7:0] xj, yj, zj,
    output [3:0] li,
    output       core_i,

    input        we_label,
    input        we_core,
    input [$clog2(MAX_N)-1:0] waddr,
    input [3:0]  wlabel,
    input        wcore,

    // STREAM WRITE
    input        we_point,
    input [$clog2(MAX_N)-1:0] waddr_point,
    input [7:0]  wx, wy, wz
);

    reg [7:0] x_mem [0:MAX_N-1];
    reg [7:0] y_mem [0:MAX_N-1];
    reg [7:0] z_mem [0:MAX_N-1];
    reg [3:0] label_mem [0:MAX_N-1];
    reg       core_mem  [0:MAX_N-1];

    integer k;
    initial begin
        for (k = 0; k < MAX_N; k = k + 1) begin
            label_mem[k] = 0;
            core_mem[k]  = 0;
        end
    end

    assign xi = x_mem[raddr_i];
    assign yi = y_mem[raddr_i];
    assign zi = z_mem[raddr_i];
    assign li = label_mem[raddr_i];
    assign core_i = core_mem[raddr_i];

    assign xj = x_mem[raddr_j];
    assign yj = y_mem[raddr_j];
    assign zj = z_mem[raddr_j];

    always @(posedge clk) begin
        if (we_point) begin
            x_mem[waddr_point] <= wx;
            y_mem[waddr_point] <= wy;
            z_mem[waddr_point] <= wz;
        end
        if (we_label)
            label_mem[waddr] <= wlabel;
        if (we_core)
            core_mem[waddr] <= wcore;
    end
endmodule
