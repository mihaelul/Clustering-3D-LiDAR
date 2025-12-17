module dbscan_top #(
    parameter MAX_N = 64
)(
    input clk,
    input rst,

    input [7:0] x, y, z,
    input valid,
    input last,

    output done
);

    reg start;
    reg [7:0] num_points;
    reg [$clog2(MAX_N)-1:0] wr_ptr;

    wire [$clog2(MAX_N)-1:0] i, j;
    wire [7:0] xi, yi, zi, xj, yj, zj;
    wire [3:0] li;
    wire core_i;
    wire [17:0] dist2;

    wire we_label, we_core;
    wire [$clog2(MAX_N)-1:0] waddr;
    wire [3:0] wlabel;
    wire wcore;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            num_points <= 0;
            start <= 0;
        end else begin
            if (valid) begin
                wr_ptr <= wr_ptr + 1;
                num_points <= num_points + 1;
            end
            if (last)
                start <= 1;
        end
    end

    dbscan_point_memory #(MAX_N) PM (
        clk,
        i, j,
        xi, yi, zi,
        xj, yj, zj,
        li,
        core_i,
        we_label,
        we_core,
        waddr,
        wlabel,
        wcore,
        valid,
        wr_ptr,
        x, y, z
    );

    dbscan_distance_unit DU (
        xi, yi, zi,
        xj, yj, zj,
        dist2
    );

    dbscan_fsm #(MAX_N) FSM (
        clk, rst,
        start,
        num_points,
        dist2,
        li,
        core_i,
        i, j,
        we_label,
        we_core,
        waddr,
        wlabel,
        wcore,
        done
    );
endmodule
