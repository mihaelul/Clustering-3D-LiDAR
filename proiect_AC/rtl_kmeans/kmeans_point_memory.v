module kmeans_point_memory #(
    parameter N = 11
)(
    input clk,

    input  [4:0] raddr,
    output [7:0] x, y, z,
    output [1:0] label,

    input        we,
    input  [4:0] waddr,
    input  [1:0] wlabel
);

    reg [7:0] x_mem [0:N-1];
    reg [7:0] y_mem [0:N-1];
    reg [7:0] z_mem [0:N-1];
    reg [1:0] label_mem [0:N-1];

    integer i;
    initial begin
        for (i = 0; i < N; i = i + 1)
            label_mem[i] = 0;
    end

    assign x = x_mem[raddr];
    assign y = y_mem[raddr];
    assign z = z_mem[raddr];
    assign label = label_mem[raddr];

    always @(posedge clk)
        if (we)
            label_mem[waddr] <= wlabel;

endmodule
