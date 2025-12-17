module point_memory #(
    parameter N = 16
)(
    input clk,

    input we,
    input [3:0] waddr,
    input [3:0] wlabel,

    input [3:0] raddr_i,
    input [3:0] raddr_j,

    output reg [7:0] xi, yi, zi,
    output reg [7:0] xj, yj, zj,
    output reg [3:0] li,
    output reg [3:0] lj
);

    reg [7:0] x_mem [0:N-1];
    reg [7:0] y_mem [0:N-1];
    reg [7:0] z_mem [0:N-1];
    reg [3:0] label_mem [0:N-1];

    integer k;
    initial begin
        for (k = 0; k < N; k = k + 1)
            label_mem[k] = 0;
    end

    always @(posedge clk) begin
        if (we)
            label_mem[waddr] <= wlabel;
    end

    always @(*) begin
        xi = x_mem[raddr_i];
        yi = y_mem[raddr_i];
        zi = z_mem[raddr_i];
        li = label_mem[raddr_i];

        xj = x_mem[raddr_j];
        yj = y_mem[raddr_j];
        zj = z_mem[raddr_j];
        lj = label_mem[raddr_j];
    end
endmodule
